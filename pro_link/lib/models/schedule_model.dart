import '../utils/json_utils.dart';

class ScheduleModel {
  const ScheduleModel({
    required this.id,
    required this.title,
    this.fileUrl,
    this.departmentId,
    this.department,
    this.uploadedBy,
    required this.validFrom,
    required this.validTo,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? fileUrl;
  final String? departmentId;
  final String? department;
  final String? uploadedBy;
  final DateTime validFrom;
  final DateTime validTo;
  final DateTime? createdAt;

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    final departmentMap = map['departments'];

    return ScheduleModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Schedule',
      fileUrl: map['file_url']?.toString(),
      departmentId: map['department_id']?.toString(),
      department:
          departmentMap is Map<String, dynamic> ? departmentMap['name']?.toString() : null,
      uploadedBy: map['uploaded_by']?.toString(),
      validFrom: JsonUtils.dateTimeOrNow(map['valid_from']),
      validTo: JsonUtils.dateTimeOrNow(map['valid_to']),
      createdAt: JsonUtils.dateTime(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'file_url': fileUrl,
      'department_id': departmentId,
      'uploaded_by': uploadedBy,
      'valid_from': validFrom.toIso8601String().split('T').first,
      'valid_to': validTo.toIso8601String().split('T').first,
    };
  }
}
