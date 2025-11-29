class GroupParticipant {
  final String id;
  final String name;
  final String? image; 
  final String githubUser;
  final double points;
  final String? role; // 'admin' ou 'member'

  const GroupParticipant({
    required this.id,
    required this.name,
    this.image,
    required this.githubUser,
    this.points = 0.0,
    this.role,
  });

  factory GroupParticipant.fromJson(Map<String, dynamic> json) {
    return GroupParticipant(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      image: json['image'] as String?,
      githubUser: (json['github_user'] ?? json['githubUser'] ?? '') as String,
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'github_user': githubUser, 
      'points': points,
      'role': role,
    };
  }
}