import 'dart:convert';

import 'package:coderats/domain/checkin/github_commit.dart';
import 'package:coderats/shared/services/storage.service.dart';
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
    String? repoUrl,
    String? githubUsername,
  }) async {
    final token = await _storage.getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }
    if (groupId.isEmpty) {
      throw Exception('groupId obrigatório para carregar commits');
    }

    final queryParameters = <String, String>{
      'page': '$page',
      'size': '$size',
      'hours': '$hours',
      if (repoUrl != null && repoUrl.isNotEmpty) 'repoUrl': repoUrl,
      if (githubUsername != null && githubUsername.isNotEmpty)
        'githubUsername': githubUsername,
    };

    final uri = Uri.parse('$_baseUrl/groups/$groupId/commits')
        .replace(queryParameters: queryParameters);

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

  Future<String?> fetchGroupRepository(String groupId) async {
    final token = await _storage.getToken();
    if (token == null) {
      throw Exception('Token não encontrado');
    }
    if (groupId.isEmpty) {
      throw Exception('groupId obrigatório para carregar repositório');
    }

    final uri = Uri.parse('$_baseUrl/groups/$groupId');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha ao carregar detalhes do grupo (status ${response.statusCode})');
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    if (decoded['group'] is Map<String, dynamic>) {
      final group = decoded['group'] as Map<String, dynamic>;
      return (group['repository'] as String?)?.trim();
    }

    return (decoded['repository'] as String?)?.trim();
  }
}
