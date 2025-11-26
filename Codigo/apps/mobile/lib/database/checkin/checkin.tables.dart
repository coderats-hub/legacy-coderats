import 'package:sqflite/sqflite.dart';

class CheckinTables {
  static Future<void> createV1(Database db) async {
    await db.execute('''
      CREATE TABLE checkins (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        summary_ai TEXT,
        points INTEGER,
        created_at TEXT,
        
        -- Dados do Autor (Denormalizados para facilitar leitura do feed)
        author_id TEXT,
        author_name TEXT,
        author_image TEXT,
        
        -- Dados Sociais
        likes_count INTEGER,
        liked_by_me INTEGER, -- 0 ou 1
        
        -- Armazenaremos comentários como JSON TEXT simples para cache
        comments_json TEXT 
      )
    ''');
  }
}