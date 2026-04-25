import '../utils/json_utils.dart';

class DepartmentModel {
  const DepartmentModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown',
      description: map['description']?.toString(),
      createdAt: JsonUtils.dateTime(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
