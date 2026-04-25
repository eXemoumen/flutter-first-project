import 'user_model.dart';

class AdminModel extends UserModel {
  const AdminModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.photoUrl,
    super.phone,
    super.isApproved = true,
    super.createdAt,
  }) : super(role: AppRole.admin);

  factory AdminModel.fromUser(UserModel user) {
    return AdminModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      photoUrl: user.photoUrl,
      phone: user.phone,
      isApproved: user.isApproved,
      createdAt: user.createdAt,
    );
  }
}
