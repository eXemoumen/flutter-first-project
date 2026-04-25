import '../utils/json_utils.dart';

class PolicyDocumentModel {
  const PolicyDocumentModel({
    required this.id,
    required this.title,
    required this.fileUrl,
    this.uploadedBy,
    this.createdAt,
  });

  final String id;
  final String title;
  final String fileUrl;
  final String? uploadedBy;
  final DateTime? createdAt;

  factory PolicyDocumentModel.fromMap(Map<String, dynamic> map) {
    return PolicyDocumentModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Policy',
      fileUrl: map['file_url']?.toString() ?? '',
      uploadedBy: map['uploaded_by']?.toString(),
      createdAt: JsonUtils.dateTime(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'file_url': fileUrl,
      'uploaded_by': uploadedBy,
    };
  }
}
