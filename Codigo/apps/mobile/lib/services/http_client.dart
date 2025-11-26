import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/env.dart';
import '../core/session_manager.dart';

class HttpClient {
  final SessionManager session;

  HttpClient(this.session);

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('${Env.baseApiUrl}$path');
    return http.get(uri, headers: await _headers());
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${Env.baseApiUrl}$path');
    return http.post(uri, headers: await _headers(), body: jsonEncode(body));
  }

  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${Env.baseApiUrl}$path');
    return http.patch(uri, headers: await _headers(), body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('${Env.baseApiUrl}$path');
    return http.delete(uri, headers: await _headers());
  }

  Future<Map<String, String>> _headers() async {
    final token = await session.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
