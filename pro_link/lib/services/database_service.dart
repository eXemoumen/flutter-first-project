import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/constants.dart';
import '../models/attendance_model.dart';
import '../models/department_model.dart';
import '../models/intern_model.dart';
import '../models/mentor_model.dart';
import '../models/policy_document_model.dart';
import '../models/schedule_model.dart';
import '../models/search_models.dart';
import '../models/skill_mark_model.dart';
import '../models/training_module_model.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService(client: ref.watch(supabaseClientProvider));
});

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalInterns,
    required this.pendingApprovals,
    required this.activeMentors,
  });

  final int totalInterns;
  final int pendingApprovals;
  final int activeMentors;
}

class DatabaseService {
  DatabaseService({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  static const _uuid = Uuid();

  static final List<UserModel> _mockUsers = [
    UserModel(
      id: 'admin-1',
      email: 'admin@prolink.test',
      fullName: 'Administrator',
      role: AppRole.admin,
      isApproved: true,
    ),
    UserModel(
      id: 'mentor-1',
      email: 'mentor1@prolink.test',
      fullName: 'Nadia Ouali',
      role: AppRole.mentor,
      isApproved: true,
    ),
    UserModel(
      id: 'mentor-2',
      email: 'mentor2@prolink.test',
      fullName: 'Samir Khelifi',
      role: AppRole.mentor,
      isApproved: true,
    ),
    UserModel(
      id: 'intern-1',
      email: 'intern1@prolink.test',
      fullName: 'Amina Bensalem',
      role: AppRole.intern,
      isApproved: true,
    ),
    UserModel(
      id: 'intern-2',
      email: 'intern2@prolink.test',
      fullName: 'Yacine Merabet',
      role: AppRole.intern,
      isApproved: false,
    ),
    UserModel(
      id: 'intern-3',
      email: 'intern3@prolink.test',
      fullName: 'Lina Ghodbane',
      role: AppRole.intern,
      isApproved: true,
    ),
  ];

  static final List<DepartmentModel> _mockDepartments = [
    const DepartmentModel(id: 'dep-1', name: 'Engineering'),
    const DepartmentModel(id: 'dep-2', name: 'IT Support'),
    const DepartmentModel(id: 'dep-3', name: 'Operations'),
    const DepartmentModel(id: 'dep-4', name: 'Finance'),
    const DepartmentModel(id: 'dep-5', name: 'HR'),
  ];

  static final List<Map<String, String?>> _mockInternProfiles = [
    {
      'user_id': 'intern-1',
      'matricule': 'INT-2401',
      'department_id': 'dep-1',
      'mentor_id': 'mentor-2',
    },
    {
      'user_id': 'intern-2',
      'matricule': 'INT-2402',
      'department_id': 'dep-2',
      'mentor_id': 'mentor-1',
    },
    {
      'user_id': 'intern-3',
      'matricule': 'INT-2403',
      'department_id': 'dep-1',
      'mentor_id': 'mentor-2',
    },
  ];

  static final List<Map<String, String?>> _mockMentorProfiles = [
    {'user_id': 'mentor-1', 'department_id': 'dep-2', 'specialization': 'Support'},
    {'user_id': 'mentor-2', 'department_id': 'dep-1', 'specialization': 'Mobile'},
  ];

  static final List<ScheduleModel> _mockSchedules = [
    ScheduleModel(
      id: 'sched-1',
      title: 'Engineering Weekly Timetable',
      fileUrl: 'https://example.com/schedules/eng-weekly.pdf',
      departmentId: 'dep-1',
      department: 'Engineering',
      uploadedBy: 'admin-1',
      validFrom: DateTime.now().subtract(const Duration(days: 2)),
      validTo: DateTime.now().add(const Duration(days: 30)),
    ),
  ];

  static final List<TrainingModuleModel> _mockModules = [
    TrainingModuleModel(
      id: 'module-1',
      title: 'Workplace Safety Basics',
      description: 'Mandatory onboarding module for interns.',
      fileUrl: 'https://example.com/training/safety.pdf',
      fileType: 'pdf',
      uploadedBy: 'mentor-2',
      departmentId: 'dep-1',
      department: 'Engineering',
    ),
  ];

  static final List<PolicyDocumentModel> _mockPolicies = [
    PolicyDocumentModel(
      id: 'policy-1',
      title: 'Corporate Internship Policy',
      fileUrl: 'https://example.com/policies/internship.pdf',
      uploadedBy: 'admin-1',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  static final List<SkillMarkModel> _mockSkillMarks = [
    SkillMarkModel(
      id: 'mark-1',
      internId: 'intern-1',
      mentorId: 'mentor-2',
      skillName: 'Technical Skills',
      mark: 17.25,
      comment: 'Strong implementation quality.',
      evaluatedAt: DateTime.now().subtract(const Duration(days: 1)),
      internName: 'Amina Bensalem',
      mentorName: 'Samir Khelifi',
    ),
  ];

  static final List<AttendanceModel> _mockAttendance = [
    AttendanceModel(
      id: 'att-1',
      internId: 'intern-1',
      mentorId: 'mentor-2',
      date: DateTime.now(),
      status: AttendanceStatus.present,
      internName: 'Amina Bensalem',
      mentorName: 'Samir Khelifi',
    ),
  ];

  bool get _enabled => _client != null;

  Future<UserModel?> fetchUserById(String userId) async {
    if (!_enabled) {
      return _mockUsers.where((e) => e.id == userId).firstOrNull;
    }

    final response = await _client!
        .from(AppConstants.usersTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  Future<UserModel?> fetchUserByEmail(String email) async {
    if (!_enabled) {
      return _mockUsers
          .where((e) => e.email.toLowerCase() == email.toLowerCase())
          .firstOrNull;
    }

    final response = await _client!
        .from(AppConstants.usersTable)
        .select()
        .eq('email', email)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  Future<void> upsertUser(UserModel user) async {
    if (!_enabled) {
      final index = _mockUsers.indexWhere((e) => e.id == user.id);
      if (index >= 0) {
        _mockUsers[index] = user;
      } else {
        _mockUsers.add(user);
      }
      return;
    }

    await _client!.from(AppConstants.usersTable).upsert(user.toMap());
  }

  Future<void> upsertInternProfile({
    required String userId,
    required String matricule,
    String? departmentId,
    String? mentorId,
    String? university,
    String? faculty,
  }) async {
    if (!_enabled) {
      final index = _mockInternProfiles.indexWhere((e) => e['user_id'] == userId);
      final profile = {
        'user_id': userId,
        'matricule': matricule,
        'department_id': departmentId,
        'mentor_id': mentorId,
      };
      if (index >= 0) {
        _mockInternProfiles[index] = profile;
      } else {
        _mockInternProfiles.add(profile);
      }
      return;
    }

    await _client!.from(AppConstants.internProfilesTable).upsert({
      'user_id': userId,
      'matricule': matricule,
      'department_id': departmentId,
      'mentor_id': mentorId,
      'university': university,
      'faculty': faculty,
    }, onConflict: 'user_id');
  }

  Future<void> upsertMentorProfile({
    required String userId,
    String? departmentId,
    String? specialization,
  }) async {
    if (!_enabled) {
      final index = _mockMentorProfiles.indexWhere((e) => e['user_id'] == userId);
      final profile = {
        'user_id': userId,
        'department_id': departmentId,
        'specialization': specialization,
      };
      if (index >= 0) {
        _mockMentorProfiles[index] = profile;
      } else {
        _mockMentorProfiles.add(profile);
      }
      return;
    }

    await _client!.from(AppConstants.mentorProfilesTable).upsert({
      'user_id': userId,
      'department_id': departmentId,
      'specialization': specialization,
    }, onConflict: 'user_id');
  }

  Future<List<DepartmentModel>> fetchDepartments() async {
    if (!_enabled) return List.of(_mockDepartments);

    final response = await _client!
        .from(AppConstants.departmentsTable)
        .select()
        .order('name');

    return response.map<DepartmentModel>(DepartmentModel.fromMap).toList();
  }

  Future<List<MentorModel>> fetchMentors() async {
    if (!_enabled) {
      return _mockUsers
          .where((u) => u.role == AppRole.mentor)
          .map((user) {
            final profile = _mockMentorProfiles.firstWhere((p) => p['user_id'] == user.id);
            final department = _mockDepartments
                .where((d) => d.id == profile['department_id'])
                .firstOrNull
                ?.name;
            return MentorModel(
              id: user.id,
              email: user.email,
              fullName: user.fullName,
              photoUrl: user.photoUrl,
              phone: user.phone,
              isApproved: user.isApproved,
              departmentId: profile['department_id'],
              department: department,
              specialization: profile['specialization'],
            );
          })
          .toList();
    }

    final response = await _client!
        .from(AppConstants.usersTable)
        .select(
          'id,email,full_name,photo_url,phone,is_approved,created_at,mentor_profiles(id,department_id,specialization,departments(name))',
        )
        .eq('role', 'mentor')
        .order('full_name');

    return response.map<MentorModel>(MentorModel.fromJoinedMap).toList();
  }

  Future<List<InternModel>> fetchInterns() async {
    if (!_enabled) {
      return _mockUsers
          .where((u) => u.role == AppRole.intern)
          .map((user) {
            final profile = _mockInternProfiles.firstWhere((p) => p['user_id'] == user.id);
            final department = _mockDepartments
                .where((d) => d.id == profile['department_id'])
                .firstOrNull
                ?.name;
            final mentor = _mockUsers
                .where((u) => u.id == profile['mentor_id'])
                .firstOrNull
                ?.fullName;
            return InternModel(
              id: user.id,
              email: user.email,
              fullName: user.fullName,
              photoUrl: user.photoUrl,
              phone: user.phone,
              isApproved: user.isApproved,
              matricule: profile['matricule'] ?? 'N/A',
              departmentId: profile['department_id'],
              department: department,
              mentorId: profile['mentor_id'],
              mentorName: mentor,
            );
          })
          .toList();
    }

    final response = await _client!
        .from(AppConstants.usersTable)
        .select(
          'id,email,full_name,photo_url,phone,is_approved,created_at,intern_profiles(id,matricule,department_id,mentor_id,university,faculty,start_date,end_date,departments(name),mentor:users!intern_profiles_mentor_id_fkey(full_name,id))',
        )
        .eq('role', 'intern')
        .order('full_name');

    return response.map<InternModel>(InternModel.fromJoinedMap).toList();
  }

  Future<List<InternModel>> fetchPendingInterns() async {
    final all = await fetchInterns();
    return all.where((e) => !e.isApproved).toList();
  }

  Future<List<InternModel>> fetchInternsByMentor(String mentorId) async {
    final all = await fetchInterns();
    return all.where((e) => e.mentorId == mentorId).toList();
  }

  Future<AdminDashboardStats> fetchAdminStats() async {
    final interns = await fetchInterns();
    final mentors = await fetchMentors();

    return AdminDashboardStats(
      totalInterns: interns.length,
      pendingApprovals: interns.where((i) => !i.isApproved).length,
      activeMentors: mentors.length,
    );
  }

  Future<void> setUserApproval({
    required String userId,
    required bool approved,
  }) async {
    if (!_enabled) {
      final index = _mockUsers.indexWhere((u) => u.id == userId);
      if (index >= 0) {
        _mockUsers[index] = _mockUsers[index].copyWith(isApproved: approved);
      }
      return;
    }

    await _client!
        .from(AppConstants.usersTable)
        .update({'is_approved': approved}).eq('id', userId);
  }

  Future<void> assignIntern({
    required String internId,
    String? departmentId,
    String? mentorId,
  }) async {
    if (!_enabled) {
      final index = _mockInternProfiles.indexWhere((e) => e['user_id'] == internId);
      if (index >= 0) {
        _mockInternProfiles[index]['department_id'] = departmentId;
        _mockInternProfiles[index]['mentor_id'] = mentorId;
      }
      return;
    }

    await _client!.from(AppConstants.internProfilesTable).upsert({
      'user_id': internId,
      'department_id': departmentId,
      'mentor_id': mentorId,
    }, onConflict: 'user_id');
  }

  Future<List<ScheduleModel>> fetchSchedulesForDepartment(String? departmentId) async {
    if (!_enabled) {
      return _mockSchedules
          .where((e) => departmentId == null || e.departmentId == departmentId)
          .toList()
        ..sort((a, b) => b.validFrom.compareTo(a.validFrom));
    }

    dynamic query = _client!
        .from(AppConstants.schedulesTable)
        .select('*,departments(name)')
        .order('created_at', ascending: false);

    if (departmentId != null && departmentId.isNotEmpty) {
      query = query.eq('department_id', departmentId);
    }

    final response = await query;
    return response.map<ScheduleModel>(ScheduleModel.fromMap).toList();
  }

  Future<void> createSchedule(ScheduleModel schedule) async {
    if (!_enabled) {
      _mockSchedules.insert(0, schedule);
      return;
    }

    await _client!.from(AppConstants.schedulesTable).insert(schedule.toMap());
  }

  Future<List<PolicyDocumentModel>> fetchPolicyDocuments() async {
    if (!_enabled) {
      return List.of(_mockPolicies)
        ..sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
    }

    final response = await _client!
        .from(AppConstants.policyDocumentsTable)
        .select()
        .order('created_at', ascending: false);

    return response.map<PolicyDocumentModel>(PolicyDocumentModel.fromMap).toList();
  }

  Future<void> createPolicyDocument(PolicyDocumentModel policy) async {
    if (!_enabled) {
      _mockPolicies.insert(0, policy);
      return;
    }

    await _client!.from(AppConstants.policyDocumentsTable).insert(policy.toMap());
  }

  Future<List<TrainingModuleModel>> fetchTrainingModulesForDepartment(
    String? departmentId,
  ) async {
    if (!_enabled) {
      return _mockModules
          .where((e) => departmentId == null || e.departmentId == departmentId)
          .toList();
    }

    dynamic query = _client!
        .from(AppConstants.trainingModulesTable)
        .select('*,departments(name)')
        .order('created_at', ascending: false);

    if (departmentId != null && departmentId.isNotEmpty) {
      query = query.eq('department_id', departmentId);
    }

    final response = await query;
    return response.map<TrainingModuleModel>(TrainingModuleModel.fromMap).toList();
  }

  Future<void> createTrainingModule(TrainingModuleModel module) async {
    if (!_enabled) {
      _mockModules.insert(0, module);
      return;
    }

    await _client!.from(AppConstants.trainingModulesTable).insert(module.toMap());
  }

  Future<void> saveSkillMark(SkillMarkModel mark) async {
    if (!_enabled) {
      _mockSkillMarks.add(mark);
      return;
    }

    await _client!.from(AppConstants.skillMarksTable).insert(mark.toMap());
  }

  Future<List<SkillMarkModel>> fetchInternSkillMarks(String internId) async {
    if (!_enabled) {
      return _mockSkillMarks.where((m) => m.internId == internId).toList()
        ..sort((a, b) => b.evaluatedAt.compareTo(a.evaluatedAt));
    }

    final response = await _client!
        .from(AppConstants.skillMarksTable)
        .select('*,intern:users!skill_marks_intern_id_fkey(full_name),mentor:users!skill_marks_mentor_id_fkey(full_name)')
        .eq('intern_id', internId)
        .order('evaluated_at', ascending: false);

    return response.map<SkillMarkModel>(SkillMarkModel.fromMap).toList();
  }

  Future<List<SkillMarkModel>> fetchMentorRecentMarks(
    String mentorId, {
    int limit = 10,
  }) async {
    if (!_enabled) {
      return _mockSkillMarks.where((m) => m.mentorId == mentorId).toList()
        ..sort((a, b) => b.evaluatedAt.compareTo(a.evaluatedAt));
    }

    final response = await _client!
        .from(AppConstants.skillMarksTable)
        .select('*,intern:users!skill_marks_intern_id_fkey(full_name),mentor:users!skill_marks_mentor_id_fkey(full_name)')
        .eq('mentor_id', mentorId)
        .order('evaluated_at', ascending: false)
        .limit(limit);

    return response.map<SkillMarkModel>(SkillMarkModel.fromMap).toList();
  }

  Future<void> saveAttendance(AttendanceModel attendance) async {
    if (!_enabled) {
      _mockAttendance.add(attendance);
      return;
    }

    await _client!.from(AppConstants.attendanceTable).insert(attendance.toMap());
  }

  Future<List<AttendanceModel>> fetchMentorAttendanceForDate(
    String mentorId,
    DateTime date,
  ) async {
    if (!_enabled) {
      return _mockAttendance
          .where(
            (a) =>
                a.mentorId == mentorId &&
                _dateKey(a.date) == _dateKey(date),
          )
          .toList();
    }

    final response = await _client!
        .from(AppConstants.attendanceTable)
        .select('*,intern:users!attendance_intern_id_fkey(full_name),mentor:users!attendance_mentor_id_fkey(full_name)')
        .eq('mentor_id', mentorId)
        .eq('date', _dateKey(date))
        .order('created_at', ascending: false);

    return response.map<AttendanceModel>(AttendanceModel.fromMap).toList();
  }

  Future<SearchResultBundle> globalSearch(String query) async {
    if (query.trim().isEmpty) return const SearchResultBundle();

    if (!_enabled) {
      final q = query.toLowerCase();
      final interns = (await fetchInterns())
          .where((i) =>
              i.fullName.toLowerCase().contains(q) ||
              i.matricule.toLowerCase().contains(q))
          .map(
            (i) => SearchItem(
              id: i.id,
              title: i.fullName,
              subtitle: '${i.matricule} • ${i.department ?? 'Unassigned'}',
              category: SearchCategory.interns,
            ),
          )
          .toList();

      final modules = _mockModules
          .where((m) => m.title.toLowerCase().contains(q))
          .map(
            (m) => SearchItem(
              id: m.id,
              title: m.title,
              subtitle: m.description ?? m.department ?? 'Training module',
              category: SearchCategory.modules,
            ),
          )
          .toList();

      final policies = _mockPolicies
          .where((p) => p.title.toLowerCase().contains(q))
          .map(
            (p) => SearchItem(
              id: p.id,
              title: p.title,
              subtitle: 'Policy document',
              category: SearchCategory.policies,
            ),
          )
          .toList();

      return SearchResultBundle(interns: interns, modules: modules, policies: policies);
    }

    final internsResponse = await _client!
        .from(AppConstants.usersTable)
        .select('id,full_name,intern_profiles(matricule,departments(name))')
        .eq('role', 'intern')
        .ilike('full_name', '%$query%')
        .limit(20);

    final modulesResponse = await _client!
        .from(AppConstants.trainingModulesTable)
        .select('id,title,description,departments(name)')
        .ilike('title', '%$query%')
        .limit(20);

    final policiesResponse = await _client!
        .from(AppConstants.policyDocumentsTable)
        .select('id,title')
        .ilike('title', '%$query%')
        .limit(20);

    final interns = internsResponse.map<SearchItem>((row) {
      final profile = row['intern_profiles'];
      String subtitle = 'Intern';
      if (profile is Map<String, dynamic>) {
        final matricule = profile['matricule']?.toString() ?? 'N/A';
        final department = profile['departments'] is Map<String, dynamic>
            ? profile['departments']['name']?.toString() ?? 'Unassigned'
            : 'Unassigned';
        subtitle = '$matricule • $department';
      }
      return SearchItem(
        id: row['id']?.toString() ?? _uuid.v4(),
        title: row['full_name']?.toString() ?? 'Intern',
        subtitle: subtitle,
        category: SearchCategory.interns,
      );
    }).toList();

    final modules = modulesResponse
        .map<SearchItem>(
          (row) => SearchItem(
            id: row['id']?.toString() ?? _uuid.v4(),
            title: row['title']?.toString() ?? 'Module',
            subtitle: row['description']?.toString() ?? 'Training module',
            category: SearchCategory.modules,
          ),
        )
        .toList();

    final policies = policiesResponse
        .map<SearchItem>(
          (row) => SearchItem(
            id: row['id']?.toString() ?? _uuid.v4(),
            title: row['title']?.toString() ?? 'Policy',
            subtitle: 'Policy document',
            category: SearchCategory.policies,
          ),
        )
        .toList();

    return SearchResultBundle(interns: interns, modules: modules, policies: policies);
  }

  String createId() => _uuid.v4();

  String _dateKey(DateTime date) => date.toIso8601String().split('T').first;
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
