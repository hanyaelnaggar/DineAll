class AuthToken {
  final String accessToken;
  final String tokenType;
  final DateTime expiresAt; // هنحسبها ونخزنها
  final String? refreshToken; // optional (لو موجود)
  final Map<String, dynamic> rawJson;

  AuthToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresAt,
    required this.rawJson,
    this.refreshToken,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool willExpireWithin(Duration d) => DateTime.now().add(d).isAfter(expiresAt);

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    final access = (json['access_token'] ?? '').toString();
    final type = (json['token_type'] ?? 'Bearer').toString();

    final expiresInRaw = json['expires_in'];
    final expiresAt = _parseExpiresAt(expiresInRaw);

    final refresh = json['refresh_token']?.toString(); // optional
    return AuthToken(
      accessToken: access,
      tokenType: type,
      expiresAt: expiresAt,
      refreshToken: refresh,
      rawJson: json,
    );
  }

  static DateTime _parseExpiresAt(dynamic expiresInRaw) {
    // في الـ Postman عندك expires_in = 1767548820 (ده شكله Unix timestamp)
    // وبعض APIs بتبقى expires_in = seconds (مثل 86400)
    final now = DateTime.now();

    if (expiresInRaw == null) return now.add(const Duration(hours: 24));

    final v = int.tryParse(expiresInRaw.toString());
    if (v == null) return now.add(const Duration(hours: 24));

    // heuristic:
    // لو رقم كبير جدًا (>= 1e9) غالبًا timestamp بالثواني
    if (v >= 1000000000) {
      return DateTime.fromMillisecondsSinceEpoch(v * 1000);
    }
    // غير كده اعتبريه seconds duration
    return now.add(Duration(seconds: v));
  }

  Map<String, dynamic> toJsonForStorage() => {
    'access_token': accessToken,
    'token_type': tokenType,
    'expires_at_ms': expiresAt.millisecondsSinceEpoch,
    'refresh_token': refreshToken,
    'raw': rawJson,
  };

  static AuthToken fromStorageJson(Map<String, dynamic> json) {
    final access = (json['access_token'] ?? '').toString();
    final type = (json['token_type'] ?? 'Bearer').toString();
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      (json['expires_at_ms'] as num).toInt(),
    );
    final refresh = json['refresh_token']?.toString();
    final raw = (json['raw'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    return AuthToken(
      accessToken: access,
      tokenType: type,
      expiresAt: expiresAt,
      refreshToken: refresh,
      rawJson: raw,
    );
  }
}
