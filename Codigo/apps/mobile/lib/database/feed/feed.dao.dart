import 'package:coderats/views/feed/domain/feed.dart';
import 'package:sqflite/sqflite.dart';

class FeedDao {
  final Database db;
  FeedDao(this.db);

  Future<void> cacheFeed(List<FeedItem> items) async {
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'feed_items',
        {
          'id': item.id,
          'title': item.title,
          'description': item.description,
          'image': item.image,
          'summary_ai': item.summaryAi,
          'points': item.points,
          'likes_count': item.likesCount,
          'user_has_liked': item.userHasLiked ? 1 : 0,
          'created_at': item.createdAt.toIso8601String(),
          'author_id': item.author.id,
          'author_name': item.author.name,
          'author_image': item.author.image,
          'author_github_user': item.author.githubUser,
          'author_role': item.author.role,
          'author_points': item.author.points,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    // Mantém somente os 10 mais recentes no cache local
    await db.rawDelete('''
      DELETE FROM feed_items
      WHERE id NOT IN (
        SELECT id FROM feed_items
        ORDER BY datetime(created_at) DESC
        LIMIT 10
      )
    ''');
  }

  Future<List<FeedItem>> getFeed(int limit, int offset) async {
    final rows = await db.query(
      'feed_items',
      orderBy: 'datetime(created_at) DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_fromRow).toList();
  }

  FeedItem _fromRow(Map<String, Object?> row) {
    return FeedItem(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String?,
      image: row['image'] as String?,
      summaryAi: row['summary_ai'] as String?,
      points: (row['points'] as num?)?.toInt() ?? 0,
      likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
      userHasLiked: (row['user_has_liked'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      author: FeedAuthor(
        id: row['author_id'] as String,
        name: row['author_name'] as String,
        image: row['author_image'] as String?,
        githubUser: row['author_github_user'] as String,
        points: (row['author_points'] as num?)?.toDouble() ?? 0,
        role: row['author_role'] as String,
      ),
    );
  }
}
