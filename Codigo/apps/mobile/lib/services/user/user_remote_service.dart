import 'dart:convert';

import 'package:app/domain/user/user.model.dart';
import 'package:app/services/http_client.dart';

class UserRemoteService {
  final HttpClient http;

  UserRemoteService(this.http);

  Future<List<User>> getAllUsers() async {
    final resp = await http.get('/users');
    if (resp.statusCode != 200) {
      throw Exception('Erro ao buscar usuários: ${resp.statusCode}');
    }

    final body = jsonDecode(resp.body);
    if (body is List) {
      return body.map((e) => User.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }

    if (body is Map && body['data'] is List) {
      final list = body['data'] as List;
      return list.map((e) => User.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }

    throw Exception('Resposta inesperada ao buscar usuários.');
  }
}
