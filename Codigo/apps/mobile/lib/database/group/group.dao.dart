import 'package:app/domain/group/group_details.dart';
import 'package:app/domain/group/group_participant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'package:app/database/app_database.dart';
import 'package:app/domain/group/group.dart';
import 'package:app/domain/user/user.model.dart';

const _uuid = Uuid();

class GroupDao {
  final Database _db;
  GroupDao(this._db);

  Map<String, Object?> _groupToMap(Group g) => {
        'id': g.id,
        'name': g.name,
        'description': g.description,
        'image': g.image,
        'code': g.code,
        'method': g.method,
        'status': g.status ? 1 : 0,
        'repository': g.repository,
        'start_date': g.startDate?.toIso8601String(),
        'end_date': g.endDate?.toIso8601String(),
      };

  Group _groupFromMap(Map<String, Object?> m) => Group(
        id: m['id'] as String,
        name: (m['name'] ?? '') as String,
        description: m['description'] as String?,
        image: m['image'] as String?,
        code: m['code'] as String?,
        method: m['method'] as String?,
        status: (m['status'] ?? 1) == 1,
        repository: m['repository'] as String?,
        startDate: m['start_date'] != null 
            ? DateTime.parse(m['start_date'] as String) 
            : null, 
        endDate: m['end_date'] != null
            ? DateTime.parse(m['end_date'] as String)
            : null,
      );

  Map<String, Object?> _userSummaryToMap(GroupParticipant m) => {
        'id': m.id,
        'name': m.name,
        'image': m.image,
        'github_user': m.githubUser,
      };
  Map<String, Object?> _userToMap(User user) => {
        'id': user.id,
        'name': user.name,
        'image': user.image,
        'github_user': user.githubUser,
      };

  GroupParticipant _memberFromJoinedRow(Map<String, Object?> row) {
    return GroupParticipant(
      id: row['u_id'] as String,
      name: (row['u_name'] ?? '') as String,
      image: row['u_image'] as String?,
      githubUser: (row['u_github_user'] ?? '') as String,
      points: (row['gp_points'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<void> cacheGroups(List<Group> groups, String userId) async {
    if (groups.isEmpty) return;
    final db = _db;

    await db.transaction((txn) async {
      for (final g in groups) {
        await txn.insert(
          'groups',
          _groupToMap(g),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final linkExists = await txn.query(
          'group_participants',
          where: 'group_id = ? AND user_id = ?',
          whereArgs: [g.id, userId],
        );

        if (linkExists.isEmpty) {
          await txn.insert('group_participants', {
            'id': _uuid.v4(),
            'group_id': g.id,
            'user_id': userId,
            'role': 'member', 
            'points': 0.0,   
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }
    });
  }

  Future<void> cacheUsers(List<User> users) async {
    if (users.isEmpty) return;
    final batch = _db.batch();
    for (final user in users) {
      batch.insert(
        'users',
        _userToMap(user),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Group>> getGroupsByUser(String userId) async {
    final db = _db;
    
    final rows = await db.rawQuery('''
      SELECT g.* FROM groups g
      INNER JOIN group_participants gp ON gp.group_id = g.id
      WHERE gp.user_id = ?
      ORDER BY g.start_date DESC
    ''', [userId]);

    return rows.map((r) => _groupFromMap(r)).toList();
  }

  Future<void> cacheGroupDetails(GroupDetails details) async {
    final db = _db;

    await db.transaction((txn) async {
      await txn.insert(
        'groups',
        _groupToMap(details.group),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete(
        'group_participants',
        where: 'group_id = ? AND role IS NULL',
        whereArgs: [details.group.id],
      );

      for (final member in details.participants) {
        await txn.insert(
          'users',
          _userSummaryToMap(member),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await txn.insert(
          'group_participants',
          {
            'id': _uuid.v4(),
            'group_id': details.group.id,
            'user_id': member.id,
            'role': null, 
            'points': member.points,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<GroupDetails?> getGroupDetails(String groupId) async {
    final db = _db;

    final groupRows = await db.query(
      'groups',
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );

    if (groupRows.isEmpty) return null;
    final group = _groupFromMap(groupRows.first);

    final joined = await db.rawQuery('''
      SELECT 
        gp.points as gp_points,
        u.id as u_id,
        u.name as u_name,
        u.image as u_image,
        u.github_user as u_github_user
      FROM group_participants gp
      JOIN users u ON u.id = gp.user_id
      WHERE gp.group_id = ?
      ORDER BY gp.points DESC
    ''', [groupId]);

    final members = joined.map((row) => _memberFromJoinedRow(row)).toList();

    return GroupDetails(group: group, participants: members);
  }

  Future<void> removeUserFromGroup(String groupId, String userId) async {
    final db = _db;
    await db.delete(
      'group_participants',
      where: 'group_id = ? AND user_id = ?',
      whereArgs: [groupId, userId],
    );
  }
}
