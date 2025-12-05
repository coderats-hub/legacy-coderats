import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../domain/checkin/checkin.dart';
import '../domain/checkin/github_commit.dart';
import 'package:coderats/shared/services/storage.service.dart';

class CheckinRepository {
  final StorageService _storage = StorageService();
  final String _baseUrl = dotenv.env['BASE_API_URL'] ?? 'http://localhost:8080';

  Future<List<Checkin>> fetchFeed({int limit = 20, int offset = 0}) async {
    final token = await _storage.getToken();
    if (token == null) throw Exception('Token não encontrado');

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

  Future<List<Checkin>> fetchMyCheckins({
    String? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final token = await _storage.getToken();
    if (token == null) throw Exception('Token nǜo encontrado');

    final qp = {
      'limit': '$limit',
      'offset': '$offset',
      if (userId != null) 'author_id': userId,
    };
    final uri = Uri.parse('$_baseUrl/checkins').replace(queryParameters: qp);

    final resp = await http.get(uri, headers: _headers(token));
    _ensureSuccess(resp, uri);

    final decoded = json.decode(resp.body);
    if (decoded is List) {
      return decoded
          .map((e) => Checkin.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    throw Exception('Formato inesperado ao carregar meus check-ins');
  }

  Future<List<Checkin>> fetchGroupCheckins(
    String groupId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final token = await _storage.getToken();
    if (token == null) throw Exception('Token não encontrado');

    final uri = Uri.parse('$_baseUrl/groups/$groupId/checkins').replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final resp = await http.get(uri, headers: _headers(token));
    _ensureSuccess(resp, uri);

    final decoded = json.decode(resp.body);
    if (decoded is List) {
      return decoded
          .map((e) => Checkin.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (decoded is Map<String, dynamic> && decoded['checkins_recentes'] is List) {
      final list = decoded['checkins_recentes'] as List<dynamic>;
      return list
          .map((e) => Checkin.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    throw Exception('Formato inesperado ao carregar check-ins do grupo');
  }

  Future<Checkin> createCheckin({
    required String groupId,
    required String title,
    String? description,
    String? image,
    String? summaryAi,
    List<GithubCommit> commits = const [],
  }) async {
    final token = await _storage.getToken();
    if (token == null) throw Exception('Token não encontrado');

    final uri = Uri.parse('$_baseUrl/groups/$groupId/checkins');

    final payload = <String, dynamic>{
      'title': title,
    };
    if (description != null && description.isNotEmpty) {
      payload['description'] = description;
    }
    if (image != null && image.isNotEmpty) {
      final uploaded = await _uploadImage(image, token);
      if (uploaded != null) {
        payload['image'] = uploaded;
      }
    }
    if (summaryAi != null && summaryAi.isNotEmpty) {
      payload['summary_ai'] = summaryAi;
    }
    if (commits.isNotEmpty) {
      payload['commits'] = commits
          .where((c) => c.repository.isNotEmpty && c.sha.isNotEmpty)
          .map((commit) => {
                'repository': commit.repository,
                'sha': commit.sha,
              })
          .toList();
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

  Future<String?> _uploadImage(String base64, String token) async {
    final bytes = base64Decode(base64);
    final uri = Uri.parse('$_baseUrl/uploads/images');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: 'checkin-image.jpg',
      contentType: MediaType.parse('image/jpeg'),
    ));
    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 201) {
      final map = json.decode(resp.body) as Map<String, dynamic>;
      return map['url'] as String?;
    }
    throw Exception('Erro ao enviar imagem: HTTP ${resp.statusCode}');
  }
}
