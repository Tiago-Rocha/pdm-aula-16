import 'dart:convert';

import 'package:http/http.dart' as http;

const baseUrl = 'https://api-pdm.sublimecipher.com';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => '$statusCode: $message';
}

/// Talks HTTP to the course API: token, headers, status codes and JSON.
/// It knows nothing about islands, forecasts or users.
class ApiClient {
  ApiClient({required this.clientId, required this.clientSecret});

  final String clientId;
  final String clientSecret;
  String? _token;

  Future<dynamic> get(String path) async {
    _token ??= await _fetchToken(); // only the first time
    final response = await http
        .get(
          Uri.parse('$baseUrl$path'),
          headers: {'Authorization': 'Bearer $_token'},
        )
        .timeout(const Duration(seconds: 10));
    _check(response);
    return jsonDecode(response.body);
  }

  /// POST with a JSON body. Returns null when the API answers 204 No Content.
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    _check(response);
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }

  Future<String> _fetchToken() async {
    final json = await post('/v1/auth/token', {
      'clientId': clientId,
      'clientSecret': clientSecret,
    }) as Map<String, dynamic>;
    return json['accessToken'] as String;
  }

  void _check(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    if (response.statusCode == 401) {
      _token = null; // expired or wrong: ask for a new one next time
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final error = body['error'] as Map<String, dynamic>;
    throw ApiException(response.statusCode, error['message'] as String);
  }
}
