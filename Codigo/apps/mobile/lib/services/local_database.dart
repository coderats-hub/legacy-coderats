import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open('coderats_cache.db');
    return _db!;
  }

  Future<Database> _open(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, v) async => _create(db),
    );
  }

  Future<void> _create(Database db) async {
    // NOTE: SQLite types mapped to Postgres semantics
    // UUID -> TEXT, TIMESTAMPTZ -> TEXT (ISO8601), BOOLEAN -> INTEGER(0/1)
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        image TEXT,
        github_user TEXT NOT NULL UNIQUE,
        github_id INTEGER NOT NULL UNIQUE,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        image TEXT,
        code TEXT UNIQUE,
        method TEXT,
        status INTEGER NOT NULL DEFAULT 1,
        repository TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE group_participants (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        role TEXT,
        points REAL DEFAULT 0,
        created_at TEXT,
        FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');
  }
}

final dbHelper = DatabaseHelper.instance;

// ===================== MODELS =====================
class User {
  final String id;
  final String name;
  final String? email;
  final String? image;
  final String githubUser;
  final int githubId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  User({
    String? id,
    required this.name,
    required this.githubUser,
    required this.githubId,
    this.email,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  }) : id = id ?? _uuid.v4();

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'image': image,
        'github_user': githubUser,
        'github_id': githubId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  factory User.fromMap(Map<String, Object?> m) => User(
        id: m['id'] as String?,
        name: (m['name'] ?? '') as String,
        email: m['email'] as String?,
        image: m['image'] as String?,
        githubUser: (m['github_user'] ?? '') as String,
        githubId: (m['github_id'] is int)
            ? (m['github_id'] as int)
            : int.parse('${m['github_id']}'),
        createdAt: _parseDate(m['created_at']),
        updatedAt: _parseDate(m['updated_at']),
        deletedAt: _parseDate(m['deleted_at']),
      );
}

class Group {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? code;
  final String? method;
  final bool status; // true active, false inactive
  final String? repository;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Group({
    String? id,
    required this.name,
    required this.startDate,
    this.description,
    this.image,
    this.code,
    this.method,
    this.status = true,
    this.repository,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  }) : id = id ?? _uuid.v4();

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'code': code,
        'method': method,
        'status': status ? 1 : 0,
        'repository': repository,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  factory Group.fromMap(Map<String, Object?> m) => Group(
        id: m['id'] as String?,
        name: (m['name'] ?? '') as String,
        description: m['description'] as String?,
        image: m['image'] as String?,
        code: m['code'] as String?,
        method: m['method'] as String?,
        status: (m['status'] is int)
            ? ((m['status'] as int) != 0)
            : ('${m['status']}' == 'true' || '${m['status']}' == '1'),
        repository: m['repository'] as String?,
        startDate: _parseDate(m['start_date']) ?? DateTime.now(),
        endDate: _parseDate(m['end_date']),
        createdAt: _parseDate(m['created_at']),
        updatedAt: _parseDate(m['updated_at']),
        deletedAt: _parseDate(m['deleted_at']),
      );
}

class GroupParticipant {
  final String id;
  final String groupId;
  final String userId;
  final String? role;
  final double points;
  final DateTime? createdAt;

  GroupParticipant({
    String? id,
    required this.groupId,
    required this.userId,
    this.role,
    this.points = 0.0,
    this.createdAt,
  }) : id = id ?? _uuid.v4();

  Map<String, Object?> toMap() => {
        'id': id,
        'group_id': groupId,
        'user_id': userId,
        'role': role,
        'points': points,
        'created_at': createdAt?.toIso8601String(),
      };

  factory GroupParticipant.fromMap(Map<String, Object?> m) => GroupParticipant(
        id: m['id'] as String?,
        groupId: (m['group_id'] ?? '') as String,
        userId: (m['user_id'] ?? '') as String,
        role: m['role'] as String?,
        points: (m['points'] is num)
            ? (m['points'] as num).toDouble()
            : double.tryParse('${m['points']}') ?? 0.0,
        createdAt: _parseDate(m['created_at']),
      );
}

class GroupDetails {
  final Group group;
  final List<GroupParticipantWithUser> participants; // enriched for ranking
  GroupDetails({required this.group, required this.participants});
}

class GroupParticipantWithUser {
  final GroupParticipant participant;
  final User user;
  GroupParticipantWithUser(this.participant, this.user);
}

DateTime? _parseDate(Object? v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v as String).toLocal();
  } catch (_) {
    return null;
  }
}

// ===================== CRUD HELPERS =====================
Future<void> insertOrReplaceUser(User u) async {
  final db = await dbHelper.database;
  await db.insert('users', u.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<void> insertOrReplaceGroup(Group g) async {
  final db = await dbHelper.database;
  await db.insert('groups', g.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<void> insertOrReplaceParticipant(GroupParticipant p) async {
  final db = await dbHelper.database;
  await db.insert('group_participants', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<Group>> getGroups() async {
  final db = await dbHelper.database;
  final maps = await db.query('groups', orderBy: 'start_date DESC');
  return maps.map((m) => Group.fromMap(m)).toList();
}

Future<List<Group>> getGroupsByUser(String userId) async {
  final db = await dbHelper.database;
  final maps = await db.rawQuery('''
    SELECT DISTINCT g.*
    FROM groups g
    INNER JOIN group_participants gp ON gp.group_id = g.id
    WHERE gp.user_id = ?
    ORDER BY g.start_date DESC
  ''', [userId]);
  return maps.map((m) => Group.fromMap(m)).toList();
}

Future<GroupDetails?> getGroupDetailsFromCache(String groupId) async {
  final db = await dbHelper.database;
  final groupRows = await db.query('groups', where: 'id = ?', whereArgs: [groupId], limit: 1);
  if (groupRows.isEmpty) return null;
  final group = Group.fromMap(groupRows.first);

  final rows = await db.rawQuery('''
    SELECT gp.*, u.id as u_id, u.name as u_name, u.email as u_email, u.image as u_image,
           u.github_user as u_github_user, u.github_id as u_github_id
    FROM group_participants gp
    JOIN users u ON u.id = gp.user_id
    WHERE gp.group_id = ?
    ORDER BY gp.points DESC
  ''', [groupId]);

  final participants = rows.map((r) {
    final p = GroupParticipant.fromMap(r);
    final user = User(
      id: r['u_id'] as String?,
      name: (r['u_name'] ?? '') as String,
      email: r['u_email'] as String?,
      image: r['u_image'] as String?,
      githubUser: (r['u_github_user'] ?? '') as String,
      githubId: (r['u_github_id'] is int)
          ? r['u_github_id'] as int
          : int.parse('${r['u_github_id']}'),
    );
    return GroupParticipantWithUser(p, user);
  }).toList();

  return GroupDetails(group: group, participants: participants);
}

Future<void> cacheGroupDetails(Group group, List<GroupParticipantWithUser> participants) async {
  final db = await dbHelper.database;
  await db.transaction((txn) async {
    await txn.insert('groups', group.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    for (final pwu in participants) {
      await txn.insert('users', pwu.user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('group_participants', pwu.participant.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  });
}

Future<void> ensureMembership(String userId, String groupId) async {
  final db = await dbHelper.database;
  final existing = await db.query(
    'group_participants',
    columns: ['id'],
    where: 'group_id = ? AND user_id = ?',
    whereArgs: [groupId, userId],
    limit: 1,
  );
  if (existing.isEmpty) {
    // Insert a minimal participant row so the offline join works.
    final p = GroupParticipant(groupId: groupId, userId: userId);
    await db.insert('group_participants', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
