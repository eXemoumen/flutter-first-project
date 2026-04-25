import 'package:flutter_test/flutter_test.dart';
import 'package:pro_link/models/user_model.dart';

void main() {
  test('UserModel map conversion', () {
    const user = UserModel(
      id: '1',
      email: 'demo@prolink.test',
      fullName: 'Demo User',
      role: AppRole.intern,
      isApproved: false,
    );

    final map = user.toMap();
    final copy = UserModel.fromMap({...map, 'created_at': DateTime.now().toIso8601String()});

    expect(copy.email, user.email);
    expect(copy.fullName, user.fullName);
    expect(copy.role, user.role);
  });
}
