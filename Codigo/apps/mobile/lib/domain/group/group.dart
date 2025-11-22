class Group {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? code;
  final String? method;
  final bool status;
  final String? repository;
  final DateTime? startDate;
  final DateTime? endDate;

  Group({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.code,
    this.method,
    this.status = true,
    this.repository,
    this.startDate,
    this.endDate,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      code: json['code'] as String?,
      method: json['method'] as String?,
      status: json['status'] == 1 || json['status'] == true,
      repository: json['repository'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'code': code,
      'method': method,
      'status': status,
      'repository': repository,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}
