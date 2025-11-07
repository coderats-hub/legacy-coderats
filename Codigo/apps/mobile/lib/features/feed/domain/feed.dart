// ==============================
// Arquivo: features/feed/domain/feed.dart
// ==============================
//
// Pasta 'domain':
// Contém modelos e regras de negócio da feature 'feed'.
//
// Este arquivo é um template com um modelo simples de FeedItem.
// Substitua/expanda conforme a necessidade da feature.

class FeedItem {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String author;
  final int likes;
  final int comments;
  final int points;
  final bool hasGithub;
  final String? githubUrl;
  // Place for future graph-related data (nodes/edges) to ease later graph implementations
  final Map<String, dynamic>? graphMeta;

  FeedItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.author,
    this.likes = 0,
    this.comments = 0,
    this.points = 0,
    this.hasGithub = false,
    this.githubUrl,
    this.graphMeta,
  });
}

// Observações:
// - Mantenha a lógica de domínio aqui (validações, conversões simples),
//   e deixe I/O, armazenamento e UI fora desta camada.
