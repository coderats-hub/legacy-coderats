/// Modelo de domínio: Badge e UserBadge
/// Seguir padrão usado no projeto (fromJson/toJson, copyWith)

class Badge {
  final String id;
  final String name;
  final String? image; // URL retornada pela API
  final String? description;
  final int points;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  /// campo usado na UI quando já tiver asset local (opcional)
  final String? imageAsset;

  /// opcional: quando badge pertence a um usuário (awarded)
  final DateTime? obtainedAt;

  const Badge({
    required this.id,
    required this.name,
    this.image,
    this.description,
    this.points = 0,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.imageAsset,
    this.obtainedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return Badge(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image'] as String?,
      description: json['description'] as String?,
      points: (json['points'] is int) ? json['points'] as int : int.tryParse('${json['points']}') ?? 0,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      deletedAt: _parseDate(json['deleted_at'] ?? json['deletedAt']),
      imageAsset: json['imageAsset'] as String?,
      obtainedAt: _parseDate(json['obtained_at'] ?? json['obtainedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    String? _toIso(DateTime? d) => d?.toIso8601String();
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'points': points,
      'created_at': _toIso(createdAt),
      'updated_at': _toIso(updatedAt),
      'deleted_at': _toIso(deletedAt),
      'imageAsset': imageAsset,
      'obtained_at': _toIso(obtainedAt),
    };
  }

  Badge copyWith({
    String? id,
    String? name,
    String? image,
    String? description,
    int? points,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? imageAsset,
    DateTime? obtainedAt,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      imageAsset: imageAsset ?? this.imageAsset,
      obtainedAt: obtainedAt ?? this.obtainedAt,
    );
  }

  @override
  String toString() {
    return 'Badge(id: $id, name: $name, points: $points)';
  }
}

/// Modelo que representa a relação user_badges (opcionalmente com nested badge)
class UserBadge {
  final String userId;
  final String badgeId;
  final int? points;
  final DateTime? awardedAt;
  final Badge? badge; // quando API retornar join com badge

  const UserBadge({
    required this.userId,
    required this.badgeId,
    this.points,
    this.awardedAt,
    this.badge,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return UserBadge(
      userId: json['user_id']?.toString() ?? '',
      badgeId: json['badge_id']?.toString() ?? '',
      points: (json['points'] is int) ? json['points'] as int : int.tryParse('${json['points']}'),
      awardedAt: _parseDate(json['awarded_at'] ?? json['awardedAt']),
      badge: json['badge'] != null && json['badge'] is Map<String, dynamic>
          ? Badge.fromJson(Map<String, dynamic>.from(json['badge']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String? _toIso(DateTime? d) => d?.toIso8601String();
    return {
      'user_id': userId,
      'badge_id': badgeId,
      'points': points,
      'awarded_at': _toIso(awardedAt),
      'badge': badge?.toJson(),
    };
  }
}
