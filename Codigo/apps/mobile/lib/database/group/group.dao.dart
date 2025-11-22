import 'package:app/domain/group/group_details.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'package:app/database/app_database.dart';
import 'package:app/domain/group/group.dart';

const _uuid = Uuid();

class GroupDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  Map<String, Object?> _groupToMap(Group g) => {
        'id': g.id,
        'name': g.name,
        'description': g.description,
        'image': g.image,
        'code': g.code,
        'method': g.method,
        'status': g.status ? 1 : 0,
        'repository': g.repository,
        'start_date': g.startDate.toIso8601String(),
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
        startDate: DateTime.parse(m['start_date'] as String),
        endDate: m['end_date'] != null
            ? DateTime.parse(m['end_date'] as String)
            : null,
      );

  Map<String, Object?> _userSummaryToMap(GroupMember m) => {
        'id': m.id,
        'name': m.name,
        'image': m.image,
        'github_user': m.githubUser,
      };

  GroupMember _memberFromJoinedRow(Map<String, Object?> row) {
    return GroupMember(
      id: row['u_id'] as String,
      name: (row['u_name'] ?? '') as String,
      image: row['u_image'] as String?,
      githubUser: (row['u_github_user'] ?? '') as String,
      points: (row['gp_points'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<void> upsertGroups(List<Group> groups) async {
    if (groups.isEmpty) return;
    final db = await _db;
    final batch = db.batch();

    for (final g in groups) {
      batch.insert(
        'groups',
        _groupToMap(g),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> upsertGroupDetails(GroupDetails details) async {
    final db = await _db;

    await db.transaction((txn) async {
      await txn.insert(
        'groups',
        _groupToMap(details.group),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final member in details.participants) {
        await txn.insert(
          'users',
          _userSummaryToMap(member),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final participantId = _uuid.v4();
        await txn.insert(
          'group_participants',
          {
            'id': participantId,
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

  Future<List<Group>> getAllGroups() async {
    final db = await _db;
    final rows = await db.query(
      'groups',
      orderBy: 'start_date DESC',
    );
    return rows.map((r) => _groupFromMap(r)).toList();
  }

  Future<GroupDetails?> getGroupDetails(String groupId) async {
    final db = await _db;

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
}
