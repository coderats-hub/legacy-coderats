class GroupParticipant {
  final String id;       
  final String name;
  final String? image;
  final double points;

  const GroupParticipant({
    required this.id,
    required this.name,
    this.image,
    required this.points,
  });
}
