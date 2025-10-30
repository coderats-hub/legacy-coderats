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
        // Cache minimal group rows (participants are cached when details are fetched)
        for (final g in groups) {
          await insertOrReplaceGroup(g);
        }
        return groups;
      } catch (_) {
        // fall through to cache
      }
    }
    // Offline or API failed
    return await getGroupsByUser(userId);
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