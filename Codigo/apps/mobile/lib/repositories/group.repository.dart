import 'package:app/domain/group/group.dart';
import 'package:app/services/group/group_remote_service.dart';

import '../core/session_manager.dart';
import '../services/connectivity_service.dart';
import '../database/group/group.dao.dart';


class GroupRepository {
  final GroupRemoteService remote;
  final GroupDao local;
  final ConnectivityService net;
  final SessionManager session;

  GroupRepository({
    required this.remote,
    required this.local,
    required this.net,
    required this.session,
  });

  Future<List<Group>> getUserGroups() async {
    final online = await net.isOnline();
    final userId = session.userId;

    if (online) {
      try {
        final groups = await remote.getUserGroups();
        await local.cacheGroups(groups, userId);
        return groups;
      } catch (_) {
      }
    }

    return await local.getGroupsByUser(userId);
  }

  Future<GroupWithDetails> getGroupDetails(String groupId) async {
    final online = await net.isOnline();

    if (online) {
      try {
        final details = await remote.getGroupDetails(groupId);
        await local.cacheGroupDetails(details);
        return details;
      } catch (_) {}
    }

    final cached = await local.getGroupDetails(groupId);
    if (cached == null) {
      throw Exception("Sem cache disponível para este grupo.");
    }
    return cached;
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

  Future<Group> updateGroup(
    String id, {
    String? name,
    String? description,
    String? image,
    List<String>? participantsRemove,
  }) async {
    return remote.updateGroup(
      id,
      name: name,
      description: description,
      image: image,
      participantsRemove: participantsRemove,
    );
  }

  Future<Group> joinGroup(String code) async {
    return remote.joinGroup(code);
  }
}
