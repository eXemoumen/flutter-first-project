import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

final authProvider = ChangeNotifierProvider<AuthController>((ref) {
  final controller = AuthController(
    authService: ref.watch(authServiceProvider),
    databaseService: ref.watch(databaseServiceProvider),
  );
  controller.initialize();
  return controller;
});

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthService authService,
    required DatabaseService databaseService,
  })  : _authService = authService,
        _databaseService = databaseService;

  final AuthService _authService;
  final DatabaseService _databaseService;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  StreamSubscription<String?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  AppRole? get role => _currentUser?.role;

  bool get isInternPendingApproval {
    final user = _currentUser;
    return user?.role == AppRole.intern && !(user?.isApproved ?? false);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    _setLoading(true);

    _authSubscription = _authService.authUserChanges().listen((userId) async {
      try {
        if (userId == null) {
          _currentUser = null;
        } else {
          final user = await _databaseService.fetchUserById(userId);
          _currentUser = user;
        }
      } catch (_) {
        _currentUser = null;
      } finally {
        _isInitialized = true;
        _setLoading(false);
        notifyListeners();
      }
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final userId = await _authService.signIn(email: email, password: password);
      _currentUser = await _databaseService.fetchUserById(userId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String email,
    required String fullName,
    required String password,
    required AppRole role,
    String? phone,
    String? matricule,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final userId = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
        matricule: matricule,
      );
      _currentUser = await _databaseService.fetchUserById(userId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    final user = _currentUser;
    if (user == null) return;

    _currentUser = await _databaseService.fetchUserById(user.id);
    notifyListeners();
  }

  Future<void> logout() async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
