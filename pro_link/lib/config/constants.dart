import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AppConstants {
  const AppConstants._();

  static const appName = 'Pro-Link';
  static const defaultAvatar = 'https://via.placeholder.com/128x128.png?text=User';

  static const avatarsBucket = 'avatars';
  static const schedulesBucket = 'schedules';
  static const trainingBucket = 'training';
  static const policiesBucket = 'policies';

  static const usersTable = 'users';
  static const departmentsTable = 'departments';
  static const internProfilesTable = 'intern_profiles';
  static const mentorProfilesTable = 'mentor_profiles';
  static const schedulesTable = 'schedules';
  static const trainingModulesTable = 'training_modules';
  static const skillMarksTable = 'skill_marks';
  static const attendanceTable = 'attendance';
  static const policyDocumentsTable = 'policy_documents';

  static bool get backendEnabled => SupabaseConfig.isConfigured;

  static const skills = <String>[
    'Communication',
    'Technical Skills',
    'Teamwork',
    'Problem Solving',
    'Time Management',
  ];

  static const departments = <String>[
    'Engineering',
    'IT Support',
    'Operations',
    'Finance',
    'HR',
  ];

  static String roleLabel(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return 'Admin';
      case AppRole.mentor:
        return 'Mentor';
      case AppRole.intern:
        return 'Intern';
    }
  }
}
