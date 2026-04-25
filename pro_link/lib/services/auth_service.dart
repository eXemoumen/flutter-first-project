import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'database_service.dart';
import 'supabase_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    client: ref.watch(supabaseClientProvider),
    databaseService: ref.watch(databaseServiceProvider),
  );
});

class AuthService {
  AuthService({
    required SupabaseClient? client,
    required DatabaseService databaseService,
  })  : _client = client,
        _databaseService = databaseService;

  final SupabaseClient? _client;
  final DatabaseService _databaseService;

  String? _mockUserId;

  bool get _enabled => _client != null;

  Stream<String?> authUserChanges() async* {
    if (!_enabled) {
      yield _mockUserId;
      return;
    }

    yield _client!.auth.currentUser?.id;
    yield* _client!.auth.onAuthStateChange.map((event) => event.session?.user.id);
  }

  Future<String?> currentAuthUserId() async {
    if (!_enabled) return _mockUserId;
    return _client!.auth.currentUser?.id;
  }

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    if (!_enabled) {
      final user = await _databaseService.fetchUserByEmail(email);
      if (user == null) {
        throw Exception('No user found for this email in mock mode.');
      }
      _mockUserId = user.id;
      return user.id;
    }

    final response = await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign-in failed.');
    }

    return user.id;
  }

  Future<String> signUp({
    required String email,
    required String password,
    required String fullName,
    required AppRole role,
    String? phone,
    String? matricule,
  }) async {
    if (!_enabled) {
      final id = _databaseService.createId();
      final user = UserModel(
        id: id,
        email: email,
        fullName: fullName,
        phone: phone,
        role: role,
        isApproved: role != AppRole.intern,
      );

      await _databaseService.upsertUser(user);
      if (role == AppRole.intern) {
        await _databaseService.upsertInternProfile(
          userId: id,
          matricule: matricule ?? 'INT-${DateTime.now().millisecondsSinceEpoch % 10000}',
        );
      }
      if (role == AppRole.mentor) {
        await _databaseService.upsertMentorProfile(userId: id);
      }

      _mockUserId = id;
      return id;
    }

    final response = await _client!.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': appRoleToString(role),
      },
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign-up failed.');
    }

    await _databaseService.upsertUser(
      UserModel(
        id: user.id,
        email: email,
        fullName: fullName,
        role: role,
        phone: phone,
        isApproved: role != AppRole.intern,
      ),
    );

    if (role == AppRole.intern) {
      await _databaseService.upsertInternProfile(
        userId: user.id,
        matricule: matricule ?? 'INT-${DateTime.now().millisecondsSinceEpoch % 10000}',
      );
    }

    if (role == AppRole.mentor) {
      await _databaseService.upsertMentorProfile(userId: user.id);
    }

    return user.id;
  }

  Future<void> signOut() async {
    if (!_enabled) {
      _mockUserId = null;
      return;
    }

    await _client!.auth.signOut();
  }
}
