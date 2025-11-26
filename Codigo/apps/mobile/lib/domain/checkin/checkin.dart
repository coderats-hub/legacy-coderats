import 'package:app/domain/checkin/checkin_author.dart';
import 'package:app/domain/checkin/checkin_comment.dart';

class Checkin {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? summaryAi; 
  final int points;        
  final DateTime createdAt;
  
  final CheckinAuthor author;
  
  // Dados Sociais
  final int likesCount;
  final bool likedByMe;
  final List<CheckinComment> comments;

  const Checkin({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.summaryAi,
    required this.points,
    required this.createdAt,
    required this.author,
    this.likesCount = 0,
    this.likedByMe = false,
    this.comments = const [],
  });

  factory Checkin.fromJson(Map<String, dynamic> json) {
    return Checkin(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image'] as String?,
      summaryAi: json['summary_ai'] as String?,
      points: json['points'] as int? ?? 0,
      
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      
      author: CheckinAuthor.fromJson(json['author'] ?? {}),
      
      likesCount: json['likes_count'] as int? ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => CheckinComment.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': imageUrl,
      'summary_ai': summaryAi,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      'author': author.toJson(),
      'likes_count': likesCount,
      'liked_by_me': likedByMe,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }
}

