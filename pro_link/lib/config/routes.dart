import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_interns_screen.dart';
import '../screens/admin/upload_policy_screen.dart';
import '../screens/admin/upload_schedule_screen.dart';
import '../screens/admin/validate_users_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/pending_approval_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/intern/digital_work_id_screen.dart';
import '../screens/intern/intern_dashboard.dart';
import '../screens/intern/intern_calendar_screen.dart';
import '../screens/intern/marks_screen.dart';
import '../screens/intern/schedule_screen.dart';
import '../screens/intern/training_screen.dart';
import '../screens/mentor/attendance_screen.dart';
import '../screens/mentor/intern_group_screen.dart';
import '../screens/mentor/mark_performance_screen.dart';
import '../screens/mentor/mentor_dashboard.dart';
import '../screens/mentor/upload_training_screen.dart';
import '../screens/shared/notifications_screen.dart';
import '../screens/shared/profile_screen.dart';
import '../screens/shared/search_screen.dart';
import '../screens/shared/settings_screen.dart';
import '../screens/shared/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthPage = path == '/login' || path == '/register';
      final isPendingPage = path == '/pending';
      final isSplash = path == '/splash';

      if (!auth.isInitialized) {
        return isSplash ? null : '/splash';
      }

      if (!auth.isLoggedIn && !isAuthPage) {
        return '/login';
      }

      if (auth.isLoggedIn && auth.isInternPendingApproval && !isPendingPage) {
        return '/pending';
      }

      if (auth.isLoggedIn && !auth.isInternPendingApproval && isPendingPage) {
        return _homeForRole(auth.role);
      }

      if (auth.isLoggedIn && isAuthPage) {
        return _homeForRole(auth.role);
      }

      if (isSplash && auth.isLoggedIn) {
        return _homeForRole(auth.role);
      }

      if (auth.isLoggedIn && path.startsWith('/admin') && auth.role != AppRole.admin) {
        return _homeForRole(auth.role);
      }

      if (auth.isLoggedIn && path.startsWith('/mentor') && auth.role != AppRole.mentor) {
        return _homeForRole(auth.role);
      }

      if (auth.isLoggedIn && path.startsWith('/intern') && auth.role != AppRole.intern) {
        return _homeForRole(auth.role);
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/pending',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboard()),
      GoRoute(
        path: '/admin/manage-interns',
        builder: (context, state) => const ManageInternsScreen(),
      ),
      GoRoute(
        path: '/admin/validate-users',
        builder: (context, state) => const ValidateUsersScreen(),
      ),
      GoRoute(
        path: '/admin/upload-schedule',
        builder: (context, state) => const UploadScheduleScreen(),
      ),
      GoRoute(
        path: '/admin/upload-policy',
        builder: (context, state) => const UploadPolicyScreen(),
      ),
      GoRoute(path: '/mentor', builder: (context, state) => const MentorDashboard()),
      GoRoute(
        path: '/mentor/intern-group',
        builder: (context, state) => const InternGroupScreen(),
      ),
      GoRoute(
        path: '/mentor/mark-performance',
        builder: (context, state) => const MarkPerformanceScreen(),
      ),
      GoRoute(
        path: '/mentor/upload-training',
        builder: (context, state) => const UploadTrainingScreen(),
      ),
      GoRoute(
        path: '/mentor/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(path: '/intern', builder: (context, state) => const InternDashboard()),
      GoRoute(
        path: '/intern/work-id',
        builder: (context, state) => const DigitalWorkIdScreen(),
      ),
      GoRoute(
        path: '/intern/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/intern/training',
        builder: (context, state) => const TrainingScreen(),
      ),
      GoRoute(path: '/intern/marks', builder: (context, state) => const MarksScreen()),
      GoRoute(
        path: '/intern/calendar',
        builder: (context, state) => const InternCalendarScreen(),
      ),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
});

String _homeForRole(AppRole? role) {
  switch (role) {
    case AppRole.admin:
      return '/admin';
    case AppRole.mentor:
      return '/mentor';
    case AppRole.intern:
      return '/intern';
    case null:
      return '/login';
  }
}
