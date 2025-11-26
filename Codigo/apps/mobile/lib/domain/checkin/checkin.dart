import 'checkin_author.dart';

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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      summaryAi: json['summary_ai'] as String?,
      points: json['points'] is int ? json['points'] as int : int.tryParse('${json['points']}') ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      author: json['author'] != null 
          ? CheckinAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : CheckinAuthor(id: '', name: 'Desconhecido'),
    );
  }
}
