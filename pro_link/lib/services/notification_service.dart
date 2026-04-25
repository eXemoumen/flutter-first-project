import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  NotificationService();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _initialized = true;
    } catch (_) {
      // Safe no-op when Firebase is not configured yet.
    }
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> subscribeToRoleTopic(String role) async {
    if (!_initialized) await initialize();
    try {
      await _messaging.subscribeToTopic('role_$role');
    } catch (_) {
      // Ignore when Firebase is unavailable.
    }
  }
}
