import 'package:app/domain/checkin/checkin_author.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app/domain/checkin/checkin.dart';

class CheckinDao {
  final Database _db;

  CheckinDao(this._db);

  // Mapeia Objeto -> SQL
  Map<String, Object?> _toContext(Checkin c) => {
        'id': c.id,
        'title': c.title,
        'description': c.description,
        'image_url': c.image,
        'summary_ai': c.summaryAi,
        'points': c.points,
        'created_at': c.createdAt.toIso8601String(),
        // Autor Flattened
        'author_id': c.author.id,
        'author_name': c.author.name,
        'author_image': c.author.image,
      };

  // Mapeia SQL -> Objeto
  Checkin _fromContext(Map<String, Object?> map) {
    return Checkin(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      image: map['image_url'] as String?,
      summaryAi: map['summary_ai'] as String?,
      points: (map['points'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      author: CheckinAuthor(
        id: map['author_id'] as String? ?? '',
        name: map['author_name'] as String? ?? 'Desconhecido',
        image: map['author_image'] as String?,
      ),
    );
  }

  Future<void> cacheFeed(List<Checkin> list) async {
    final batch = _db.batch();
    for (final item in list) {
      batch.insert(
        'checkins',
        _toContext(item),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Checkin>> getFeed() async {
    final rows = await _db.query(
      'checkins',
      orderBy: 'created_at DESC', // Feed ordenado por data
    );
    return rows.map((r) => _fromContext(r)).toList();
  }
}