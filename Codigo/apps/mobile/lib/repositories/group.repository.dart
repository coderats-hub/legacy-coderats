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
    if (userId == null) return [];

    final online = await net.isOnline();

    if (online) {
      try {
        final groups = await remote.getUserGroups();
        // Só salva no cache se o banco local existir (Mobile)
        if (local != null) {
          await local!.cacheGroups(groups, userId);
        }
        return groups;
      } catch (e) {
        // Se der erro na API, tenta o cache
      }
    }

    // Se tiver banco local, busca dele. Se não (Web offline), retorna vazio.
    if (local != null) {
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
}