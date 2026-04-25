import '../utils/json_utils.dart';

enum AppRole { admin, mentor, intern }

AppRole appRoleFromString(String value) {
  switch (value.toLowerCase()) {
    case 'admin':
      return AppRole.admin;
    case 'mentor':
      return AppRole.mentor;
    case 'intern':
      return AppRole.intern;
    default:
      throw ArgumentError('Unknown role: $value');
  }
}

String appRoleToString(AppRole role) {
  switch (role) {
    case AppRole.admin:
      return 'admin';
    case AppRole.mentor:
      return 'mentor';
    case AppRole.intern:
      return 'intern';
  }
}

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.photoUrl,
    this.phone,
    this.isApproved = false,
    this.createdAt,
  });

  final String id;
  final String email;
  final String fullName;
  final AppRole role;
  final String? photoUrl;
  final String? phone;
  final bool isApproved;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': appRoleToString(role),
      'photo_url': photoUrl,
      'phone': phone,
      'is_approved': isApproved,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      role: appRoleFromString((map['role'] ?? 'intern').toString()),
      photoUrl: map['photo_url']?.toString(),
      phone: map['phone']?.toString(),
      isApproved: JsonUtils.toBool(map['is_approved']),
      createdAt: JsonUtils.dateTime(map['created_at']),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    AppRole? role,
    String? photoUrl,
    String? phone,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
