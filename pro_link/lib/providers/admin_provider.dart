import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/department_model.dart';
import '../models/intern_model.dart';
import '../models/mentor_model.dart';
import '../models/policy_document_model.dart';
import '../models/schedule_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

final adminProvider = ChangeNotifierProvider<AdminController>((ref) {
  return AdminController(
    databaseService: ref.watch(databaseServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

class AdminController extends ChangeNotifier {
  AdminController({
    required DatabaseService databaseService,
    required StorageService storageService,
  })  : _databaseService = databaseService,
        _storageService = storageService;

  final DatabaseService _databaseService;
  final StorageService _storageService;

  bool _isLoading = false;
  String? _error;

  int _totalInterns = 0;
  int _pendingApprovals = 0;
  int _activeMentors = 0;

  List<InternModel> _interns = const [];
  List<InternModel> _pendingUsers = const [];
  List<MentorModel> _mentors = const [];
  List<DepartmentModel> _departments = const [];
  List<PolicyDocumentModel> _policies = const [];
  List<ScheduleModel> _schedules = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalInterns => _totalInterns;
  int get pendingApprovals => _pendingApprovals;
  int get activeMentors => _activeMentors;
  List<InternModel> get interns => _interns;
  List<InternModel> get pendingUsers => _pendingUsers;
  List<MentorModel> get mentors => _mentors;
  List<DepartmentModel> get departments => _departments;
  List<PolicyDocumentModel> get policies => _policies;
  List<ScheduleModel> get schedules => _schedules;

  Future<void> loadDashboard() async {
    await _runGuarded(() async {
      final stats = await _databaseService.fetchAdminStats();
      _totalInterns = stats.totalInterns;
      _pendingApprovals = stats.pendingApprovals;
      _activeMentors = stats.activeMentors;
    });
  }

  Future<void> loadManageInternData() async {
    await _runGuarded(() async {
      _interns = await _databaseService.fetchInterns();
      _mentors = await _databaseService.fetchMentors();
      _departments = await _databaseService.fetchDepartments();
    });
  }

  Future<void> loadPendingUsers() async {
    await _runGuarded(() async {
      _pendingUsers = await _databaseService.fetchPendingInterns();
    });
  }

  Future<void> approveUser(String userId) async {
    await _runGuarded(() async {
      await _databaseService.setUserApproval(userId: userId, approved: true);
      await loadPendingUsers();
      await loadDashboard();
    });
  }

  Future<void> rejectUser(String userId) async {
    await _runGuarded(() async {
      await _databaseService.setUserApproval(userId: userId, approved: false);
      await loadPendingUsers();
      await loadDashboard();
    });
  }

  Future<void> assignIntern({
    required String internId,
    String? departmentId,
    String? mentorId,
  }) async {
    await _runGuarded(() async {
      await _databaseService.assignIntern(
        internId: internId,
        departmentId: departmentId,
        mentorId: mentorId,
      );
      await loadManageInternData();
    });
  }

  Future<void> loadSchedules() async {
    await _runGuarded(() async {
      _schedules = await _databaseService.fetchSchedulesForDepartment(null);
    });
  }

  Future<void> uploadSchedule({
    required String title,
    required String departmentId,
    required String uploaderId,
    required DateTime from,
    required DateTime to,
    required String localFilePath,
  }) async {
    await _runGuarded(() async {
      final fileUrl = await _storageService.uploadSchedule(localFilePath);
      final schedule = ScheduleModel(
        id: _databaseService.createId(),
        title: title,
        fileUrl: fileUrl,
        departmentId: departmentId,
        uploadedBy: uploaderId,
        validFrom: from,
        validTo: to,
      );

      await _databaseService.createSchedule(schedule);
      await loadSchedules();
    });
  }

  Future<void> loadPolicies() async {
    await _runGuarded(() async {
      _policies = await _databaseService.fetchPolicyDocuments();
    });
  }

  Future<void> uploadPolicy({
    required String title,
    required String uploaderId,
    required String localFilePath,
  }) async {
    await _runGuarded(() async {
      final fileUrl = await _storageService.uploadPolicyFile(localFilePath);
      final policy = PolicyDocumentModel(
        id: _databaseService.createId(),
        title: title,
        fileUrl: fileUrl,
        uploadedBy: uploaderId,
        createdAt: DateTime.now(),
      );

      await _databaseService.createPolicyDocument(policy);
      await loadPolicies();
    });
  }

  Future<void> _runGuarded(Future<void> Function() action) async {
    _setLoading(true);
    _error = null;

    try {
      await action();
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
}
