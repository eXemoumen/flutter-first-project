import '../utils/json_utils.dart';

class TrainingModuleModel {
  const TrainingModuleModel({
    required this.id,
    required this.title,
    this.description,
    required this.fileUrl,
    this.fileType,
    this.uploadedBy,
    this.departmentId,
    this.department,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String fileUrl;
  final String? fileType;
  final String? uploadedBy;
  final String? departmentId;
  final String? department;
  final DateTime? createdAt;

  factory TrainingModuleModel.fromMap(Map<String, dynamic> map) {
    final departmentMap = map['departments'];

    return TrainingModuleModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Module',
      description: map['description']?.toString(),
      fileUrl: map['file_url']?.toString() ?? '',
      fileType: map['file_type']?.toString(),
      uploadedBy: map['uploaded_by']?.toString(),
      departmentId: map['department_id']?.toString(),
      department:
          departmentMap is Map<String, dynamic> ? departmentMap['name']?.toString() : null,
      createdAt: JsonUtils.dateTime(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'file_type': fileType,
      'uploaded_by': uploadedBy,
      'department_id': departmentId,
    };
  }
}
