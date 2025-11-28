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
  
  // Extrai apenas a descrição antes dos commits
  String? get cleanDescription {
    if (description == null) return null;
    final parts = description!.split('\n\nCommits selecionados:');
    if (parts.isEmpty) return description;
    return parts[0].trim().isEmpty ? null : parts[0].trim();
  }
  
  // Extrai a lista de commits
  List<String> get commits {
    if (description == null || !hasGithub) return [];
    final parts = description!.split('Commits selecionados:');
    if (parts.length < 2) return [];
    
    final commitSection = parts[1].trim();
    return commitSection
        .split('\n')
        .where((line) => line.trim().startsWith('-'))
        .map((line) => line.trim().substring(1).trim())
        .toList();
  }
  
  // Conta quantos commits foram selecionados
  int get commitsCount => commits.length;
}

// Observações:
// - Mantenha a lógica de domínio aqui (validações, conversões simples),
//   e deixe I/O, armazenamento e UI fora desta camada.
