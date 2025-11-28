class CheckinAuthor {
  final String id;
  final String name;
  final String? image;
  final String githubUser;
  final double points;
  final String? role;

  CheckinAuthor({
    required this.id,
    required this.name,
    this.image,
    required this.githubUser,
    required this.points,
    this.role,
  });

  factory CheckinAuthor.fromJson(Map<String, dynamic> json) {
    return CheckinAuthor(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      image: json['image'] as String?,
      githubUser: (json['github_user'] ?? '') as String,
      // Garante conversão segura de int/double
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
      role: json['role'] as String?,
    );
  }
}
