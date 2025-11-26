import 'package:app/domain/checkin/checkin_author.dart';

class CheckinComment {
  final String id;
  final String content;
  final CheckinAuthor author;

  const CheckinComment({
    required this.id,
    required this.content,
    required this.author,
  });

  factory CheckinComment.fromJson(Map<String, dynamic> json) {
    return CheckinComment(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      author: CheckinAuthor.fromJson(json['author'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'author': author.toJson(),
      };
}