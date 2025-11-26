import 'dart:convert';
import 'package:http/http.dart' as http;

import 'http_client.dart';

class ApiException implements Exception {
  final int statusCode;
  final String body;
  final String? message;

  ApiException(this.statusCode, this.body, {this.message});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message, body: $body)';
}

class ApiService {
  final HttpClient _http;

  ApiService(this._http);

  Future<dynamic> getJson(String path) async {
    final resp = await _http.get(path);
    _checkError(resp);
    if (resp.body.isEmpty) return null;
    return jsonDecode(resp.body);
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final resp = await _http.post(path, body);
    _checkError(resp);
    if (resp.body.isEmpty) return null;
    return jsonDecode(resp.body);
  }

  Future<dynamic> patchJson(String path, Map<String, dynamic> body) async {
    final resp = await _http.patch(path, body);
    _checkError(resp);
    if (resp.body.isEmpty) return null;
    return jsonDecode(resp.body);
  }

  Future<dynamic> deleteJson(String path) async {
    final resp = await _http.delete(path);
    _checkError(resp);
    if (resp.body.isEmpty) return null;
    return jsonDecode(resp.body);
  }

  void _checkError(http.Response resp) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) return;

    throw ApiException(
      resp.statusCode,
      resp.body,
      message: 'Erro HTTP ${resp.statusCode}',
    );
  }
}
