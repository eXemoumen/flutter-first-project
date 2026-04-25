import '../utils/json_utils.dart';
import 'user_model.dart';

class MentorModel extends UserModel {
  const MentorModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.photoUrl,
    super.phone,
    super.isApproved = true,
    super.createdAt,
    this.profileId,
    this.departmentId,
    this.department,
    this.specialization,
  }) : super(role: AppRole.mentor);

  final String? profileId;
  final String? departmentId;
  final String? department;
  final String? specialization;

  factory MentorModel.fromJoinedMap(Map<String, dynamic> map) {
    final profile = map['mentor_profiles'];
    final departmentMap = profile is Map<String, dynamic> ? profile['departments'] : null;

    return MentorModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      photoUrl: map['photo_url']?.toString(),
      phone: map['phone']?.toString(),
      isApproved: JsonUtils.toBool(map['is_approved'], fallback: true),
      createdAt: JsonUtils.dateTime(map['created_at']),
      profileId: profile is Map<String, dynamic> ? profile['id']?.toString() : null,
      departmentId: profile is Map<String, dynamic> ? profile['department_id']?.toString() : null,
      department: departmentMap is Map<String, dynamic>
          ? departmentMap['name']?.toString()
          : profile is Map<String, dynamic>
              ? profile['department']?.toString()
              : null,
      specialization:
          profile is Map<String, dynamic> ? profile['specialization']?.toString() : null,
    );
  }

  @override
  MentorModel copyWith({
    String? id,
    String? email,
    String? fullName,
    AppRole? role,
    String? photoUrl,
    String? phone,
    bool? isApproved,
    DateTime? createdAt,
    String? profileId,
    String? departmentId,
    String? department,
    String? specialization,
  }) {
    return MentorModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      profileId: profileId ?? this.profileId,
      departmentId: departmentId ?? this.departmentId,
      department: department ?? this.department,
      specialization: specialization ?? this.specialization,
    );
  }
}
