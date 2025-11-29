import 'package:sqflite/sqflite.dart';

class FeedTables {
  static Future<void> createV1(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS feed_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        image TEXT,
        summary_ai TEXT,
        points INTEGER NOT NULL,
        likes_count INTEGER NOT NULL,
        user_has_liked INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        author_image TEXT,
        author_github_user TEXT NOT NULL,
        author_role TEXT,
        author_points REAL
      );
    ''');
  }
}
