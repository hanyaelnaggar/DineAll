import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_token.dart';

class TokenStore {
  static const _kAuthKey = 'auth_token_bundle';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> save(AuthToken token) async {
    final jsonStr = jsonEncode(token.toJsonForStorage());
    await _storage.write(key: _kAuthKey, value: jsonStr);
  }

  Future<AuthToken?> read() async {
    final v = await _storage.read(key: _kAuthKey);
    if (v == null || v.isEmpty) return null;
    final map = (jsonDecode(v) as Map).cast<String, dynamic>();
    return AuthToken.fromStorageJson(map);
  }

  Future<void> clear() => _storage.delete(key: _kAuthKey);
}
