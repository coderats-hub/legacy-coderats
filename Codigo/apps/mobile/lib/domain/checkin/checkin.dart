import 'package:app/domain/checkin/checkin_author.dart';

class Checkin {
  final String id;
  final String title;
  final String? description;
  final String? image;
  final String? summaryAi;
  final int points;
  final DateTime createdAt;
  final CheckinAuthor author;

  Checkin({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.summaryAi,
    required this.points,
    required this.createdAt,
    required this.author,
  });

  factory Checkin.fromJson(Map<String, dynamic> json) {
    return Checkin(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      summaryAi: json['summary_ai'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      author: CheckinAuthor.fromJson(json['author'] as Map<String, dynamic>),
    );
  }
}
