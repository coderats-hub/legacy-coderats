import 'dart:convert';

import 'package:app/domain/group/group.dart';
import 'package:app/domain/group/group_details.dart';
import 'package:app/services/http_client.dart';

class GroupRemoteService {
  final HttpClient http;

  GroupRemoteService(this.http);

  Future<List<Group>> getUserGroups() async {
    final resp = await http.get('/users/me/groups');

    if (resp.statusCode != 200) {
      throw Exception('Erro ao buscar grupos: ${resp.statusCode}');
    }

    final list = jsonDecode(resp.body) as List;
    return list.map((e) => Group.fromJson(e)).toList();
  }

  Future<GroupDetails> getGroupDetails(String id) async {
    final resp = await http.get('/groups/$id');

    if (resp.statusCode != 200) {
      throw Exception('Erro ao buscar detalhes: ${resp.statusCode}');
    }

    final map = jsonDecode(resp.body);
    return GroupDetails.fromJson(map);
  }

  Future<Group> createGroup({
    required String name,
    String? description,
    String? image,
    String? method,
    String? repository,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final body = {
      'name': name,
      'description': description,
      'image': image,
      'method': method,
      'repository': repository,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };

    final resp = await http.post('/groups', body);

    if (resp.statusCode != 201) {
      throw Exception('Erro ao criar grupo: ${resp.statusCode}');
    }

    return Group.fromJson(jsonDecode(resp.body));
  }

  Future<Group> updateGroup(
    String id, {
    String? name,
    String? description,
    String? image,
    List<String>? participantsRemove,
  }) async {
    final body = {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      if (participantsRemove != null)
        'participants_remove': participantsRemove,
    };

    final resp = await http.patch('/groups/$id', body);

    if (resp.statusCode != 200) {
      throw Exception('Erro ao atualizar grupo: ${resp.statusCode}');
    }

    return Group.fromJson(jsonDecode(resp.body));
  }

  Future<Group> joinGroup(String code) async {
    final resp = await http.post('/groups/join', {'code': code});

    if (resp.statusCode != 201) {
      throw Exception('Erro ao entrar no grupo: ${resp.statusCode}');
    }

    final map = jsonDecode(resp.body);
    return Group.fromJson(map['group']);
  }
}
