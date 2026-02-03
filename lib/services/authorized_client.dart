import 'package:http/http.dart' as http;
import 'token_manager.dart';

class AuthorizedClient extends http.BaseClient {
  AuthorizedClient(this._inner, this._tokenManager);

  final http.Client _inner;
  final TokenManager _tokenManager;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _tokenManager.getValidAccessToken();

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // log request (اختياري)
    // ignore: avoid_print
    print('[AuthorizedClient] ➡️ ${request.method} ${request.url}');
    // ignore: avoid_print
    print('[AuthorizedClient] Headers: ${request.headers}');

    final res = await _inner.send(request);

    // log response status
    // ignore: avoid_print
    print('[AuthorizedClient] ⬅️ status=${res.statusCode} for ${request.url}');
    return res;
  }
}
