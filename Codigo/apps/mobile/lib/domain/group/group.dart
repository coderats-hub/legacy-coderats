class Group {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final bool status;
  final String? code;
  final String? method;
  final String? repository;
  final DateTime? startDate;
  final DateTime? endDate;

  const Group({
    required this.id,
    required this.name,
    required this.status,
    this.description,
    this.image,
    this.code,
    this.method,
    this.repository,
    this.startDate,
    this.endDate,
  });
}
