class CheckinAuthor {
  final String id;
  final String name;
  final String? image;

  const CheckinAuthor({
    required this.id,
    required this.name,
    this.image,
  });

  factory CheckinAuthor.fromJson(Map<String, dynamic> json) {
    return CheckinAuthor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Desconhecido',
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
      };
}
