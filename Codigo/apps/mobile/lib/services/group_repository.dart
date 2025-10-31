import 'api_service.dart';
import 'local_database.dart';
import 'connectivity_service.dart';


/// Repository implementing Online‑first + cache fallback
class GroupRepository {
  final _net = ConnectivityService();


  /// List groups the user participates in.
  Future<List<Group>> getUserGroups(String userId) async {
    final online = await _net.isOnline();
    if (online) {
      try {
        final groups = await fetchGroupsForUser(userId);

        // Cache groups + ensure membership so offline join works.
        for (final g in groups) {
          await insertOrReplaceGroup(g);
          await ensureMembership(userId, g.id); // <— add this line
        }

        return groups;
      } catch (_) {
        // fall through to cache
      }
    }

    // Offline or API failed — read from cache.
    final cached = await getGroupsByUser(userId);

    // Safety net: if for some reason membership wasn’t written yet,
    // still show whatever groups we have cached.
    if (cached.isEmpty) {
      return await getGroups();
    }
    return cached;
  }



  /// Get details (group + participants ranking)
  Future<GroupDetails?> getGroupDetails(String groupId) async {
    final online = await _net.isOnline();
    if (online) {
      try {
        final details = await fetchGroupDetails(groupId);
        await cacheGroupDetails(details.group, details.participants);
        return details;
      } catch (_) {
        // ignore and try cache
      }
    }
    return await getGroupDetailsFromCache(groupId);
  }
}