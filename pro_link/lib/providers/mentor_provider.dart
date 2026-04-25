import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance_model.dart';
import '../models/intern_model.dart';
import '../models/skill_mark_model.dart';
import '../models/training_module_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

final mentorProvider = ChangeNotifierProvider<MentorController>((ref) {
  return MentorController(
    databaseService: ref.watch(databaseServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

class MentorController extends ChangeNotifier {
  MentorController({
    required DatabaseService databaseService,
    required StorageService storageService,
  })  : _databaseService = databaseService,
        _storageService = storageService;

  final DatabaseService _databaseService;
  final StorageService _storageService;

  bool _isLoading = false;
  String? _error;

  List<InternModel> _internGroup = const [];
  List<SkillMarkModel> _recentMarks = const [];
  List<AttendanceModel> _attendanceByDate = const [];
  List<TrainingModuleModel> _trainingModules = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<InternModel> get internGroup => _internGroup;
  List<SkillMarkModel> get recentMarks => _recentMarks;
  List<AttendanceModel> get attendanceByDate => _attendanceByDate;
  List<TrainingModuleModel> get trainingModules => _trainingModules;
  int get groupSize => _internGroup.length;

  Future<void> loadDashboard(String mentorId) async {
    await _runGuarded(() async {
      _internGroup = await _databaseService.fetchInternsByMentor(mentorId);
      _recentMarks = await _databaseService.fetchMentorRecentMarks(mentorId, limit: 8);
      _attendanceByDate =
          await _databaseService.fetchMentorAttendanceForDate(mentorId, DateTime.now());
    });
  }

  Future<void> loadInternGroup(String mentorId) async {
    await _runGuarded(() async {
      _internGroup = await _databaseService.fetchInternsByMentor(mentorId);
    });
  }

  Future<void> submitPerformanceMarks({
    required String mentorId,
    required String internId,
    required Map<String, double> marks,
    required Map<String, String> comments,
  }) async {
    await _runGuarded(() async {
      for (final entry in marks.entries) {
        final mark = SkillMarkModel(
          id: _databaseService.createId(),
          internId: internId,
          mentorId: mentorId,
          skillName: entry.key,
          mark: entry.value,
          comment: comments[entry.key],
          evaluatedAt: DateTime.now(),
        );
        await _databaseService.saveSkillMark(mark);
      }

      _recentMarks = await _databaseService.fetchMentorRecentMarks(mentorId, limit: 8);
    });
  }

  Future<void> loadAttendanceForDate({
    required String mentorId,
    required DateTime date,
  }) async {
    await _runGuarded(() async {
      _attendanceByDate = await _databaseService.fetchMentorAttendanceForDate(mentorId, date);
    });
  }

  Future<void> submitAttendance({
    required String mentorId,
    required DateTime date,
    required Map<String, AttendanceStatus> byIntern,
  }) async {
    await _runGuarded(() async {
      for (final entry in byIntern.entries) {
        final attendance = AttendanceModel(
          id: _databaseService.createId(),
          internId: entry.key,
          mentorId: mentorId,
          date: date,
          status: entry.value,
        );
        await _databaseService.saveAttendance(attendance);
      }

      _attendanceByDate = await _databaseService.fetchMentorAttendanceForDate(mentorId, date);
    });
  }

  Future<void> loadTrainingModules(String? departmentId) async {
    await _runGuarded(() async {
      _trainingModules =
          await _databaseService.fetchTrainingModulesForDepartment(departmentId);
    });
  }

  Future<void> uploadTrainingModule({
    required String title,
    required String description,
    required String departmentId,
    required String uploaderId,
    required String localPath,
  }) async {
    await _runGuarded(() async {
      final fileUrl = await _storageService.uploadTrainingFile(localPath);
      final extension = _fileExtension(localPath);

      final module = TrainingModuleModel(
        id: _databaseService.createId(),
        title: title,
        description: description,
        fileUrl: fileUrl,
        fileType: extension,
        uploadedBy: uploaderId,
        departmentId: departmentId,
      );

      await _databaseService.createTrainingModule(module);
      await loadTrainingModules(departmentId);
    });
  }

  String _fileExtension(String path) {
    final idx = path.lastIndexOf('.');
    if (idx <= 0 || idx == path.length - 1) return 'file';
    return path.substring(idx + 1).toLowerCase();
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
