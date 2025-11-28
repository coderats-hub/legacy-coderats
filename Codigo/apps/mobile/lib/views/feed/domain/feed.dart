// ==============================
// Arquivo: features/feed/domain/feed.dart
// ==============================
//
// Pasta 'domain':
// Contém modelos e regras de negócio da feature 'feed'.
//
// Este arquivo é um template com um modelo simples de FeedItem.
// Substitua/expanda conforme a necessidade da feature.

class FeedAuthor {
  final String id;
  final String name;
  final String? image;
  final String githubUser;
  final double points;
  final String role;

  FeedAuthor({
    required this.id,
    required this.name,
    this.image,
    required this.githubUser,
    required this.points,
    required this.role,
  });

  factory FeedAuthor.fromJson(Map<String, dynamic> json) {
    return FeedAuthor(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      githubUser: json['github_user'] as String,
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
      role: json['role'] as String,
    );
  }
}

class FeedItem {
  final String id;
  final String title;
  final String? description;
  final String? image;
  final String? summaryAi;
  final int points;
  final DateTime createdAt;
  final FeedAuthor author;

  FeedItem({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.summaryAi,
    required this.points,
    required this.createdAt,
    required this.author,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      summaryAi: json['summary_ai'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      author: FeedAuthor.fromJson(json['author'] as Map<String, dynamic>),
    );
  }

  bool get hasGithub => description?.contains('Commits selecionados:') ?? false;
}

// Observações:
// - Mantenha a lógica de domínio aqui (validações, conversões simples),
//   e deixe I/O, armazenamento e UI fora desta camada.
