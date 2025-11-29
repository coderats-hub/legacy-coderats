import 'package:sqflite/sqflite.dart';

class GroupTables {
  static Future<void> createV1(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        image TEXT,
        github_user TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        image TEXT,
        code TEXT,
        method TEXT,
        status INTEGER NOT NULL DEFAULT 1, -- 1 = ativo, 0 = inativo
        repository TEXT,
        start_date TEXT NOT NULL,          -- ISO8601
        end_date TEXT                      -- ISO8601, nullable
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
