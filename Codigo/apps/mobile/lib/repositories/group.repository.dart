import 'package:app/domain/group/group.dart';
import 'package:app/domain/group/group_details.dart';
import 'package:app/services/group/group_remote_service.dart';
import 'package:app/database/group/group.dao.dart';
import 'package:app/services/connectivity_service.dart';
import 'package:app/core/session_manager.dart';

class GroupRepository {
  final GroupRemoteService remote;
  final GroupDao? local; // <--- AGORA É OPCIONAL (NULLABLE)
  final ConnectivityService net;
  final SessionManager session;

  GroupRepository({
    required this.remote,
    this.local,          // <--- REMOVIDO 'required'
    required this.net,
    required this.session,
  });

  Future<List<Group>> getUserGroups() async {
    final userId = session.currentUserId;
    final online = await net.isOnline();

    if (online) {
      try {
        final groups = await remote.getUserGroups();
        // Só salva no cache se o banco local existir (Mobile) e tivermos um usuário
        if (local != null && userId != null) {
          await local!.cacheGroups(groups, userId);
        }
        return groups;
      } catch (e) {
        // Se der erro na API, tenta o cache
      }
    }

    // Se tiver banco local e usuário conhecido, busca dele. Se não (Web/offline), retorna vazio.
    if (local != null && userId != null) {
      return await local!.getGroupsByUser(userId);
    }
    return []; 
  }

  Future<GroupDetails> getGroupDetails(String groupId) async {
    final online = await net.isOnline();

    if (online) {
      try {
        final details = await remote.getGroupDetails(groupId);
        if (local != null) {
          await local!.cacheGroupDetails(details);
        }
        return details;
      } catch (e) {}
    }

    if (local != null) {
      final cached = await local!.getGroupDetails(groupId);
      if (cached != null) return cached;
    }
    
    throw Exception("Dados não disponíveis offline.");
  }

  // Métodos de escrita (create, update) continuam iguais pois só usam 'remote'
  Future<Group> createGroup({
    required String name,
    String? description,
    String? image,
    String? method,
    String? repository,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return remote.createGroup(
      name: name,
      description: description,
      image: image,
      method: method,
      repository: repository,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<String> joinGroup(String code) async {
    final online = await net.isOnline();
    if (!online) {
      throw Exception('Conexao com a internet indisponivel.');
    }

    final group = await remote.joinGroup(code);
    final userId = session.currentUserId;

    if (local != null && userId != null) {
      await local!.cacheGroups([group], userId);
    }

    return group.id;
  }

  Future<void> leaveGroup(String groupId) async {
    final online = await net.isOnline();
    if (!online) {
      throw Exception('Conexão com a internet indisponível.');
    }

    final userId = session.currentUserId;
    if (userId == null) {
      throw Exception('Usuário não autenticado.');
    }

    await remote.leaveGroup(groupId, userId);

    // Remove do cache local
    if (local != null) {
      await local!.removeUserFromGroup(groupId, userId);
    }
  }
}
