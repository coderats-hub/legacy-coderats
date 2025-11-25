import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../domain/checkin.dart';
import 'package:app/shared/services/storage.service.dart';

class CheckinRepository {
  final StorageService _storage = StorageService();
  final String _baseUrl = dotenv.env['BASE_API_URL'] ?? 'http://localhost:8080';

  Future<List<Checkin>> fetchFeed({int limit = 20, int offset = 0}) async {
    final token = await _storage.getToken();
    if (token == null) throw Exception('Token n\u00e3o encontrado');

    final uri = Uri.parse('$_baseUrl/feed').replace(queryParameters: {
      'limit': '$limit',
      'offset': '$offset',
    });

    final resp = await http.get(uri, headers: _headers(token));
    _ensureSuccess(resp, uri);

    final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
    return data
        .map((e) => Checkin.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<Checkin>> fetchGroupCheckins(
    String groupId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final token = await _storage.getToken();
    if (token == null) throw Exception('Token n\u00e3o encontrado');

    final uri = Uri.parse('$_baseUrl/groups/$groupId/checkins').replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final resp = await http.get(uri, headers: _headers(token));
    _ensureSuccess(resp, uri);

    final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
    return data
        .map((e) => Checkin.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Checkin> createCheckin({
    required String groupId,
    required String title,
    String? description,
    String? image,
    String? summaryAi,
  }) async {
    final token = await _storage.getToken();
    if (token == null) throw Exception('Token n\u00e3o encontrado');

    final uri = Uri.parse('$_baseUrl/groups/$groupId/checkins');

    final payload = <String, dynamic>{
      'title': title,
    };
    if (description != null && description.isNotEmpty) {
      payload['description'] = description;
    }
    if (image != null && image.isNotEmpty) {
      payload['image'] = image;
    }
    if (summaryAi != null && summaryAi.isNotEmpty) {
      payload['summary_ai'] = summaryAi;
    }

    final resp = await http.post(
      uri,
      headers: _headers(token),
      body: json.encode(payload),
    );
    _ensureSuccess(resp, uri);

    final Map<String, dynamic> data =
        json.decode(resp.body) as Map<String, dynamic>;
    return Checkin.fromJson(data);
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };

  void _ensureSuccess(http.Response resp, Uri uri) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return;
    }
    throw Exception(
        'Request to ${uri.path} failed with status ${resp.statusCode}');
  }
}
