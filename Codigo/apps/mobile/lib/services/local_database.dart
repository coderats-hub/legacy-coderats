import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/group/group.dao.dart';

class LocalDatabase {
  static LocalDatabase? _instance;

  final Database _db;

  late final GroupDao groups;

  LocalDatabase._(this._db) {
    groups = GroupDao(_db);
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

  Database get raw => _db;

  Future<void> close() async {
    await _db.close();
    _instance = null;
  }
}
