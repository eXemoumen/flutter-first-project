import '../utils/json_utils.dart';
import 'user_model.dart';

class InternModel extends UserModel {
  const InternModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.photoUrl,
    super.phone,
    super.isApproved = false,
    super.createdAt,
    required this.matricule,
    this.profileId,
    this.departmentId,
    this.department,
    this.mentorId,
    this.mentorName,
    this.university,
    this.faculty,
    this.startDate,
    this.endDate,
  }) : super(role: AppRole.intern);

  final String matricule;
  final String? profileId;
  final String? departmentId;
  final String? department;
  final String? mentorId;
  final String? mentorName;
  final String? university;
  final String? faculty;
  final DateTime? startDate;
  final DateTime? endDate;

  factory InternModel.fromJoinedMap(Map<String, dynamic> map) {
    final profile = map['intern_profiles'];

    final departmentMap = profile is Map<String, dynamic> ? profile['departments'] : null;
    final mentorMap = profile is Map<String, dynamic> ? profile['mentor'] : null;

    return InternModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      photoUrl: map['photo_url']?.toString(),
      phone: map['phone']?.toString(),
      isApproved: JsonUtils.toBool(map['is_approved']),
      createdAt: JsonUtils.dateTime(map['created_at']),
      matricule: profile is Map<String, dynamic>
          ? profile['matricule']?.toString() ?? 'N/A'
          : 'N/A',
      profileId: profile is Map<String, dynamic> ? profile['id']?.toString() : null,
      departmentId: profile is Map<String, dynamic> ? profile['department_id']?.toString() : null,
      department: departmentMap is Map<String, dynamic>
          ? departmentMap['name']?.toString()
          : profile is Map<String, dynamic>
              ? profile['department']?.toString()
              : null,
      mentorId: profile is Map<String, dynamic> ? profile['mentor_id']?.toString() : null,
      mentorName: mentorMap is Map<String, dynamic>
          ? mentorMap['full_name']?.toString()
          : null,
      university: profile is Map<String, dynamic> ? profile['university']?.toString() : null,
      faculty: profile is Map<String, dynamic> ? profile['faculty']?.toString() : null,
      startDate:
          profile is Map<String, dynamic> ? JsonUtils.dateTime(profile['start_date']) : null,
      endDate: profile is Map<String, dynamic> ? JsonUtils.dateTime(profile['end_date']) : null,
    );
  }

  InternModel copyWith({
    String? matricule,
    String? profileId,
    String? departmentId,
    String? department,
    String? mentorId,
    String? mentorName,
    String? university,
    String? faculty,
    DateTime? startDate,
    DateTime? endDate,
    bool? isApproved,
  }) {
    return InternModel(
      id: id,
      email: email,
      fullName: fullName,
      photoUrl: photoUrl,
      phone: phone,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt,
      matricule: matricule ?? this.matricule,
      profileId: profileId ?? this.profileId,
      departmentId: departmentId ?? this.departmentId,
      department: department ?? this.department,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
