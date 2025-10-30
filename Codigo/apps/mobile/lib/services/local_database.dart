import 'dart:async';
// Flutter widgets import removed because it's unused in this file.
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

/// ===============================================================
///  DATABASE HELPER (Singleton)
/// ===============================================================
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('coderats_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      // Habilita as chaves estrangeiras toda vez que o banco é aberto.
      onConfigure: _onConfigure,
      onCreate: _createDB,
    );
  }

  // NOVO MÉTODO: Executa comandos na configuração do banco.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // MÉTODO ATUALIZADO com as constraints e foreign keys
  Future<void> _createDB(Database db, int version) async {
    // 1. USERS TABLE - types aligned with Postgres semantics
    // Using TEXT for UUIDs, TIMESTAMPTZ stored as ISO8601 TEXT
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        image TEXT,
        github_user TEXT NOT NULL UNIQUE,
        github_id INTEGER NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      );
    ''');

    // 2. GROUPS TABLE - Sem alterações, já estava correta.
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
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      );
    ''');

    // 3. GROUP_PARTICIPANTS TABLE - Grandes melhorias aqui!
    await db.execute('''
      CREATE TABLE group_participants (
        user_id TEXT NOT NULL,
        group_id TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'member' CHECK(role IN ('admin', 'member')),
        points INTEGER NOT NULL DEFAULT 0,
        joined_at TEXT NOT NULL,
        PRIMARY KEY (user_id, group_id),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE
      );
    ''');
  }

  /// Fecha o banco de dados se estiver aberto.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

// ===================================================
// USER MODEL
// ===================================================
class User {
  final String id;
  final String name;
  final String email;
  final String? image;
  final String githubUser;
  final int githubId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  User({
    String? id,
    required this.name,
    required this.email,
    this.image,
    required this.githubUser,
    required this.githubId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  }) : id = id ?? uuid.v4();

  Map<String, Object?> toMap() {
    return {
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
  }

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      image: map['image'] as String?,
      githubUser: map['github_user'] as String,
      githubId: map['github_id'] as int,
  createdAt: _tryParseIso(map['created_at'] as String?),
  updatedAt: _tryParseIso(map['updated_at'] as String?),
  deletedAt: _tryParseIso(map['deleted_at'] as String?),
    );
  }
}



// ===================================================
// GROUP MODEL
// ===================================================
class Group {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? code;
  final String? method;
  final bool status;
  final String? repository;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? createdAt; 
  final DateTime? updatedAt;  
  final DateTime? deletedAt; 

  Group({
    String? id,
    required this.name,
    this.description,
    this.image,
    this.code,
    this.method,
    this.status = true,
    this.repository,
    required this.startDate,
    this.endDate,
    this.createdAt, 
    this.updatedAt, 
    this.deletedAt, 
  }) : id = id ?? uuid.v4();

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'code': code,
      'method': method,
      'status': status ? 1 : 0, // boolean -> integer
      'repository': repository,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(), 
      'updated_at': updatedAt?.toIso8601String(),  
      'deleted_at': deletedAt?.toIso8601String(), 
    };
  }

  factory Group.fromMap(Map<String, Object?> map) {
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      image: map['image'] as String?,
      code: map['code'] as String?,
      method: map['method'] as String?,
  status: ((map['status'] as int?) ?? 1) == 1,
      repository: map['repository'] as String?,
  startDate: DateTime.parse(map['start_date'] as String),
  endDate: _tryParseIso(map['end_date'] as String?),
  createdAt: _tryParseIso(map['created_at'] as String?),
  updatedAt: _tryParseIso(map['updated_at'] as String?),
  deletedAt: _tryParseIso(map['deleted_at'] as String?),
    );
  }
}

// ===================================================
// GROUP PARTICIPANT MODEL
// ===================================================
class GroupParticipant {
  final String userId;
  final String groupId;
  final String role;
  final int points;
  final DateTime joinedAt; 

  GroupParticipant({
    required this.userId,
    required this.groupId,
    this.role = 'member',
    this.points = 0,
    required this.joinedAt, 
  });

  Map<String, Object?> toMap() {
    return {
      'user_id': userId,
      'group_id': groupId,
      'role': role,
      'points': points,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  factory GroupParticipant.fromMap(Map<String, Object?> map) {
    return GroupParticipant(
      userId: map['user_id'] as String,
      groupId: map['group_id'] as String,
      role: map['role'] as String,
  points: map['points'] as int,
  joinedAt: _tryParseIso(map['joined_at'] as String?) ?? DateTime.now(),
    );
  }
}

final dbHelper = DatabaseHelper.instance;

// Helper: safe ISO8601 parser
DateTime? _tryParseIso(String? s) => s == null ? null : DateTime.tryParse(s);

// Ensure timestamps exist for non-nullable DB columns
Map<String, Object?> _ensureTimestamps(Map<String, Object?> map) {
  final now = DateTime.now().toIso8601String();
  return {
    ...map,
    'created_at': map['created_at'] ?? now,
    'updated_at': map['updated_at'] ?? now,
  };
}

// =============================
// USERS CRUD
// =============================
Future<void> insertUser(User user) async {
  final db = await dbHelper.database;
  final map = _ensureTimestamps(user.toMap());
  final updated = await db.update('users', map, where: 'id = ?', whereArgs: [user.id]);
  if (updated == 0) {
    await db.insert('users', map);
  }
}

Future<List<User>> getUsers() async {
  final db = await dbHelper.database;
  final maps = await db.query('users');
  return maps.map((m) => User.fromMap(m)).toList();
}

Future<void> updateUser(User user) async {
  final db = await dbHelper.database;
  await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
}

Future<void> deleteUser(String id) async {
  final db = await dbHelper.database;
  await db.delete('users', where: 'id = ?', whereArgs: [id]);
}

// =============================
// GROUPS CRUD
// =============================
Future<void> insertGroup(Group group) async {
  final db = await dbHelper.database;
  final map = _ensureTimestamps(group.toMap());
  final updated = await db.update('groups', map, where: 'id = ?', whereArgs: [group.id]);
  if (updated == 0) {
    await db.insert('groups', map);
  }
}

Future<List<Group>> getGroups() async {
  final db = await dbHelper.database;
  final maps = await db.query('groups');
  return maps.map((m) => Group.fromMap(m)).toList();
}

Future<void> updateGroup(Group group) async {
  final db = await dbHelper.database;
  await db.update('groups', group.toMap(), where: 'id = ?', whereArgs: [group.id]);
}

Future<void> deleteGroup(String id) async {
  final db = await dbHelper.database;
  await db.delete('groups', where: 'id = ?', whereArgs: [id]);
}

// =============================
// GROUP PARTICIPANTS CRUD
// =============================
Future<void> insertGroupParticipant(GroupParticipant gp) async {
  final db = await dbHelper.database;
  final map = gp.toMap();
  final updated = await db.update(
    'group_participants',
    map,
    where: 'user_id = ? AND group_id = ?',
    whereArgs: [gp.userId, gp.groupId],
  );
  if (updated == 0) {
    await db.insert('group_participants', map);
  }
}

Future<List<GroupParticipant>> getGroupParticipants() async {
  final db = await dbHelper.database;
  final maps = await db.query('group_participants');
  return maps.map((m) => GroupParticipant.fromMap(m)).toList();
}

Future<void> updateGroupParticipant(GroupParticipant gp) async {
  final db = await dbHelper.database;
  await db.update(
    'group_participants',
    gp.toMap(),
    where: 'user_id = ? AND group_id = ?',
    whereArgs: [gp.userId, gp.groupId],
  );
}

Future<void> deleteGroupParticipant(String userId, String groupId) async {
  final db = await dbHelper.database;
  await db.delete(
    'group_participants',
    where: 'user_id = ? AND group_id = ?',
    whereArgs: [userId, groupId],
  );
}

// Buscar participantes de um grupo específico
Future<List<GroupParticipant>> getGroupParticipantsByGroup(String groupId) async {
  final db = await dbHelper.database;
  final maps = await db.query(
    'group_participants',
    where: 'group_id = ?',
    whereArgs: [groupId],
  );
  return maps.map((m) => GroupParticipant.fromMap(m)).toList();
}

// Buscar usuários de um grupo
Future<List<User>> getUsersByGroup(String groupId) async {
  final db = await dbHelper.database;
  final maps = await db.rawQuery('''
    SELECT u.* FROM users u
    INNER JOIN group_participants gp ON u.id = gp.user_id
    WHERE gp.group_id = ?
  ''', [groupId]);
  
  return maps.map((m) => User.fromMap(m)).toList();
}

// Buscar grupos de um usuário
Future<List<Group>> getGroupsByUser(String userId) async {
  final db = await dbHelper.database;
  final maps = await db.rawQuery('''
    SELECT g.* FROM groups g
    INNER JOIN group_participants gp ON g.id = gp.group_id
    WHERE gp.user_id = ?
  ''', [userId]);
  
  return maps.map((m) => Group.fromMap(m)).toList();
}