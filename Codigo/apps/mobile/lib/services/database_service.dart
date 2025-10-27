import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
    join(await getDatabasesPath(), 'coderats_database.db'),

    onCreate: (db, version) async {
      // =============================
      // 1. USERS TABLE
      // =============================
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,                      -- simulate UUID with TEXT
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          image TEXT,
          github_user TEXT,
          
          created_at TEXT NOT NULL DEFAULT (datetime('now')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now')),
          deleted_at TEXT
        )
      ''');

      // =============================
      // 2. GROUPS TABLE
      // =============================
      await db.execute('''
        CREATE TABLE groups (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          image TEXT,
          code TEXT UNIQUE,
          method TEXT,
          status TEXT NOT NULL,
          repository TEXT,
          start_date TEXT NOT NULL,
          end_date TEXT,
          
          created_at TEXT NOT NULL DEFAULT (datetime('now')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now')),
          deleted_at TEXT
        )
      ''');

      // =============================
      // 3. GROUP_PARTICIPANTS TABLE
      // =============================
      await db.execute('''
        CREATE TABLE group_participants (
          user_id TEXT NOT NULL,
          group_id TEXT NOT NULL,
          role TEXT NOT NULL DEFAULT 'member',
          points INTEGER NOT NULL DEFAULT 0,
          joined_at TEXT NOT NULL DEFAULT (datetime('now')),

          PRIMARY KEY (user_id, group_id),
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
        )
      ''');
    },

    version: 1,
  );

  final db = await database;
  print("Database successfully initialized at: ${db.path}");
}

// =============================
// USERS CRUD
// =============================

Future<void> insertUser(User user) async {
  final db = await database;
  await db.insert(
    'users',
    user.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<User>> users() async {
  final db = await database;
  final List<Map<String, Object?>> maps = await db.query('users');
  return [
    for (final m in maps)
      User(
        id: m['id'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
        password: m['password'] as String,
        image: m['image'] as String?,
        githubUser: m['github_user'] as String?,
      )
  ];
}

Future<void> updateUser(User user) async {
  final db = await database;
  await db.update(
    'users',
    user.toMap(),
    where: 'id = ?',
    whereArgs: [user.id],
  );
}

Future<void> deleteUser(String id) async {
  final db = await database;
  await db.delete(
    'users',
    where: 'id = ?',
    whereArgs: [id],
  );
}

// =============================
// GROUPS CRUD
// =============================

Future<void> insertGroup(Group group) async {
  final db = await database;
  await db.insert(
    'groups',
    group.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Group>> groups() async {
  final db = await database;
  final List<Map<String, Object?>> maps = await db.query('groups');
  return [
    for (final m in maps)
      Group(
        id: m['id'] as String,
        name: m['name'] as String,
        description: m['description'] as String?,
        image: m['image'] as String?,
        code: m['code'] as String?,
        method: m['method'] as String?,
        status: m['status'] as String,
        repository: m['repository'] as String?,
        startDate: m['start_date'] as String,
        endDate: m['end_date'] as String?,
      )
  ];
}

Future<void> updateGroup(Group group) async {
  final db = await database;
  await db.update(
    'groups',
    group.toMap(),
    where: 'id = ?',
    whereArgs: [group.id],
  );
}

Future<void> deleteGroup(String id) async {
  final db = await database;
  await db.delete(
    'groups',
    where: 'id = ?',
    whereArgs: [id],
  );
}

// =============================
// GROUP_PARTICIPANTS CRUD
// =============================

Future<void> insertGroupParticipant(GroupParticipant participant) async {
  final db = await database;
  await db.insert(
    'group_participants',
    participant.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<GroupParticipant>> groupParticipants() async {
  final db = await database;
  final List<Map<String, Object?>> maps = await db.query('group_participants');
  return [
    for (final m in maps)
      GroupParticipant(
        userId: m['user_id'] as String,
        groupId: m['group_id'] as String,
        role: m['role'] as String,
        points: m['points'] as int,
      )
  ];
}

Future<void> updateGroupParticipant(GroupParticipant participant) async {
  final db = await database;
  await db.update(
    'group_participants',
    participant.toMap(),
    where: 'user_id = ? AND group_id = ?',
    whereArgs: [participant.userId, participant.groupId],
  );
}

Future<void> deleteGroupParticipant(String userId, String groupId) async {
  final db = await database;
  await db.delete(
    'group_participants',
    where: 'user_id = ? AND group_id = ?',
    whereArgs: [userId, groupId],
  );
}

// =============================
// MODELS
// =============================

import 'package:uuid/uuid.dart';

final uuid = const Uuid();

//User model
class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? image;
  final String? githubUser;

  User({
    String? id,
    required this.name,
    required this.email,
    required this.password,
    this.image,
    this.githubUser,
  }) : id = id ?? uuid.v4();

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'image': image,
      'github_user': githubUser,
    };
  }

  @override
  String toString() => 'User{id: $id, name: $name, email: $email}';
}

//Group model
class Group {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? code;
  final String? method;
  final String status;
  final String? repository;
  final String startDate;
  final String? endDate;

  Group({
    String? id,
    required this.name,
    this.description,
    this.image,
    this.code,
    this.method,
    required this.status,
    this.repository,
    required this.startDate,
    this.endDate,
  }) : id = id ?? uuid.v4();

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'code': code,
      'method': method,
      'status': status,
      'repository': repository,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  @override
  String toString() => 'Group{id: $id, name: $name, status: $status}';
}

//GroupParticipant model
class GroupParticipant {
  final String userId;
  final String groupId;
  final String role;
  final int points;

  GroupParticipant({
    required this.userId,
    required this.groupId,
    this.role = 'member',
    this.points = 0,
  });

  Map<String, Object?> toMap() {
    return {
      'user_id': userId,
      'group_id': groupId,
      'role': role,
      'points': points,
    };
  }

  @override
  String toString() =>
      'GroupParticipant{user_id: $userId, group_id: $groupId, role: $role, points: $points}';
}

//Exemplo de uso

//Cria usuário, grupo e adiciona o usuário ao grupo
void main() async {
  final newUser = User(
    name: 'Ana Coder',
    email: 'ana@coderats.com',
    password: '123456',
  );

  await insertUser(newUser);
  print(await users());

  final newGroup = Group(
    name: 'Desafio 30 Dias',
    status: 'active',
    startDate: DateTime.now().toIso8601String(),
  );

  await insertGroup(newGroup);
  print(await groups());

  await insertGroupParticipant(
    GroupParticipant(userId: newUser.id, groupId: newGroup.id),
  );

  print(await groupParticipants());
}

