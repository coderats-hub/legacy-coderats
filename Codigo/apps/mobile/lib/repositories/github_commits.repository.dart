import 'dart:convert';

import 'package:app/domain/checkin/github_commit.dart';
import 'package:app/shared/services/storage.service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GithubCommitsRepository {
  GithubCommitsRepository()
      : _baseUrl = dotenv.env['BASE_API_URL'] ?? 'http://localhost:8080';

  final StorageService _storage = StorageService();
  final String _baseUrl;

  Future<List<GithubCommit>> fetchCommits({
    required String groupId,
    int page = 1,
    int size = 5,
    int hours = 24,
  }) async {
    final token = await _storage.getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }
    if (groupId.isEmpty) {
      throw Exception('groupId obrigatório para carregar commits');
    }

    final uri = Uri.parse('$_baseUrl/groups/$groupId/commits').replace(
      queryParameters: {
        'page': '$page',
        'size': '$size',
        'hours': '$hours',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao carregar commits (status ${response.statusCode})');
    }

    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data
        .map((item) =>
            GithubCommit.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
