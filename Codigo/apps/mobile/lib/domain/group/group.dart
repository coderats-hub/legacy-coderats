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
    final rawStatus = json['status'];
    bool statusValue = true;
    if (rawStatus is bool) {
      statusValue = rawStatus;
    } else if (rawStatus is num) {
      statusValue = rawStatus == 1;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value);
      }
      return null;
    }

    final startRaw = json['start_date'] ?? json['startDate'];
    final endRaw = json['end_date'] ?? json['endDate'];

    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      code: json['code'] as String?,
      method: json['method'] as String?,
      status: statusValue,
      repository: json['repository'] as String?,
      startDate: parseDate(startRaw),
      endDate: parseDate(endRaw),
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
