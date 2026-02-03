import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_api.dart';
import 'auth_token.dart';
import 'token_store.dart';

class TokenManager {
  TokenManager({
    required AuthApi authApi,
    required TokenStore tokenStore,
    this.renewBefore = const Duration(minutes: 5),
    this.persistCredentials = false,
  })  : _authApi = authApi,
        _tokenStore = tokenStore;

  final AuthApi _authApi;
  final TokenStore _tokenStore;
  final Duration renewBefore;

  // لو true هتخزن userName/password/branchName في secure storage (أقل أمانًا)
  final bool persistCredentials;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  static const _kUser = 'auth_userName';
  static const _kPass = 'auth_password';
  static const _kBranch = 'auth_branchName';

  // in-memory session creds (الأفضل)
  String? _sessionUser;
  String? _sessionPass;
  String? _sessionBranch;

  Future<void> setSessionCredentials({
    required String userName,
    required String password,
    required String branchName,
  }) async {
    _sessionUser = userName;
    _sessionPass = password;
    _sessionBranch = branchName;

    if (persistCredentials) {
      await _secure.write(key: _kUser, value: userName);
      await _secure.write(key: _kPass, value: password);
      await _secure.write(key: _kBranch, value: branchName);
    }
  }

  Future<AuthToken?> _loadToken() => _tokenStore.read();

  Future<String> getValidAccessToken() async {
    final token = await _loadToken();

    // لو مفيش token أو منتهي
    if (token == null || token.isExpired || token.willExpireWithin(renewBefore)) {
      final renewed = await _renewToken();
      return renewed.accessToken;
    }

    return token.accessToken;
  }

  Future<AuthToken> _renewToken() async {
    final creds = await _getCredentials();
    if (creds == null) {
      throw Exception('No credentials available to renew token');
    }

    final newToken = await _authApi.authenticate(
      userName: creds.userName,
      password: creds.password,
      branchName: creds.branchName,
    );
    await _tokenStore.save(newToken);
    return newToken;
  }

  Future<void> saveInitialTokenFromLogin(AuthToken token) => _tokenStore.save(token);

  Future<_Creds?> _getCredentials() async {
    // أولاً: session memory
    if (_sessionUser != null && _sessionPass != null && _sessionBranch != null) {
      return _Creds(_sessionUser!, _sessionPass!, _sessionBranch!);
    }

    // ثانيًا: secure storage لو مفعّل
    if (persistCredentials) {
      final u = await _secure.read(key: _kUser);
      final p = await _secure.read(key: _kPass);
      final b = await _secure.read(key: _kBranch);
      if (u != null && p != null && b != null) return _Creds(u, p, b);
    }

    return null;
  }
}

class _Creds {
  final String userName;
  final String password;
  final String branchName;
  _Creds(this.userName, this.password, this.branchName);
}
