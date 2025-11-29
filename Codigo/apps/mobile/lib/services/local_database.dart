import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/group/group.dao.dart';
import '../database/feed/feed.dao.dart';

class LocalDatabase {
  static LocalDatabase? _instance;

  final Database _db;

  late final GroupDao groups;
  late final FeedDao feed;

  LocalDatabase._(this._db) {
    groups = GroupDao(_db);
    feed = FeedDao(_db);
  }

  static Future<LocalDatabase> getInstance() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'LocalDatabase/SQLite não é suportado no Web. '
        'No Web, use apenas chamadas HTTP (sem offline).',
      );
    }

    if (_instance != null) return _instance!;

    final db = await AppDatabase.open();
    _instance = LocalDatabase._(db);
    return _instance!;
  }

  static Future<LocalDatabase?> maybeGetInstance() async {
    if (kIsWeb) return null;
    return getInstance();
  }

  static Future<GroupDao?> maybeGetGroupDao() async {
    final instance = await maybeGetInstance();
    return instance?.groups;
  }

  Database get raw => _db;

  Future<void> close() async {
    await _db.close();
    _instance = null;
  }
}
