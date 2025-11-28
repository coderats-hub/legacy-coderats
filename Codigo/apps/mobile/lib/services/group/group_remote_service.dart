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
      _throwHttp('Erro ao buscar grupos', resp);
    }

    final list = jsonDecode(resp.body) as List;
    return list.map((e) => Group.fromJson(e)).toList();
  }

  Future<GroupDetails> getGroupDetails(String id) async {
    final resp = await http.get('/groups/$id/checkins');

    if (resp.statusCode != 200) {
      _throwHttp('Erro ao buscar detalhes', resp);
    }

    final list = jsonDecode(resp.body) as List;

    return GroupDetails.fromCheckinList(id, list);
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
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
    };

    final resp = await http.post('/groups', body);

    if (resp.statusCode != 201) {
      _throwHttp('Erro ao criar grupo', resp);
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
      if (participantsRemove != null) 'participants_remove': participantsRemove,
    };

    final resp = await http.patch('/groups/$id', body);

    if (resp.statusCode != 200) {
      _throwHttp('Erro ao atualizar grupo', resp);
    }

    return Group.fromJson(jsonDecode(resp.body));
  }

  Future<Group> joinGroup(String code) async {
    final resp = await http.post('/groups/join', {'code': code});

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      _throwHttp('Erro ao entrar no grupo', resp);
    }

    final map = jsonDecode(resp.body);
    return Group.fromJson(map['group']);
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    final resp = await http.patch('/groups/$groupId', {
      'remove_participants': [userId],
    });

    if (resp.statusCode != 200) {
      _throwHttp('Erro ao sair do grupo', resp);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    final resp = await http.delete('/groups/$groupId');

    if (resp.statusCode != 204 && resp.statusCode != 200) {
      if (resp.statusCode == 410) {
        throw Exception('Este grupo já está inativo');
      } else if (resp.statusCode == 403) {
        throw Exception('Apenas administradores podem excluir o grupo');
      }
      _throwHttp('Erro ao excluir grupo', resp);
    }
  }

  String _formatDate(DateTime date) => date.toUtc().toIso8601String();

  Never _throwHttp(String fallback, dynamic resp) {
    String message = '$fallback: HTTP ${resp.statusCode}';
    try {
      final Map<String, dynamic> body =
          jsonDecode(resp.body) as Map<String, dynamic>;
      final details =
          body['message'] ?? body['error'] ?? body['detail'] ?? body['errors'];
      if (details != null) {
        message = '$fallback: $details';
      }
    } catch (_) {}
    throw Exception(message);
  }
}
