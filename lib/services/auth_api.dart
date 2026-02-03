import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_token.dart';

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String tokenUrl = 'https://integracore.acthosts.com/oauth2/token';

  Future<AuthToken> authenticate({
    required String userName,
    required String password,
    required String branchName,
  }) async {
    final uri = Uri.parse(tokenUrl);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final body = {
      'userName': userName,
      'password': password,
      'branchName': branchName,
    };

    _log('➡️ AUTH POST $tokenUrl');
    _log('Headers: $headers');
    _log('Body: ${jsonEncode(body)}');

    final res = await _client.post(uri, headers: headers, body: jsonEncode(body));

    _log('⬅️ AUTH status=${res.statusCode}');
    _log('Response headers: ${res.headers}');
    _log('Response body: ${res.body}');

    if (res.body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final jsonBody = (jsonDecode(res.body) as Map).cast<String, dynamic>();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final token = AuthToken.fromJson(jsonBody);

      if (token.accessToken.isEmpty) {
        throw Exception('No access_token returned');
      }
      return token;
    }

    final msg = jsonBody['message']?.toString() ?? 'Authentication failed';
    throw Exception(msg);
  }

  void _log(String m) {
    // ignore: avoid_print
    print('[AuthApi] $m');
  }
}
