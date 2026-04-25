import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/calendar_event_model.dart';
import '../models/intern_model.dart';
import '../models/schedule_model.dart';
import '../models/skill_mark_model.dart';
import '../models/training_module_model.dart';
import '../services/database_service.dart';

final internProvider = ChangeNotifierProvider<InternController>((ref) {
  return InternController(databaseService: ref.watch(databaseServiceProvider));
});

class InternController extends ChangeNotifier {
  InternController({required DatabaseService databaseService})
      : _databaseService = databaseService;

  final DatabaseService _databaseService;

  bool _isLoading = false;
  String? _error;

  InternModel? _intern;
  List<ScheduleModel> _schedules = const [];
  List<TrainingModuleModel> _modules = const [];
  List<SkillMarkModel> _marks = const [];
  List<CalendarEventModel> _events = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  InternModel? get intern => _intern;
  List<ScheduleModel> get schedules => _schedules;
  List<TrainingModuleModel> get modules => _modules;
  List<SkillMarkModel> get marks => _marks;
  List<CalendarEventModel> get events => _events;

  double get averageMark {
    if (_marks.isEmpty) return 0;
    return _marks.map((e) => e.mark).reduce((a, b) => a + b) / _marks.length;
  }

  Future<void> loadAll(String userId) async {
    await _runGuarded(() async {
      final interns = await _databaseService.fetchInterns();
      _intern = interns.where((e) => e.id == userId).firstOrNull;
      final departmentId = _intern?.departmentId;

      _schedules = await _databaseService.fetchSchedulesForDepartment(departmentId);
      _modules = await _databaseService.fetchTrainingModulesForDepartment(departmentId);
      _marks = await _databaseService.fetchInternSkillMarks(userId);

      _events = _buildCalendarEvents();
    });
  }

  Future<void> refreshSchedules() async {
    final departmentId = _intern?.departmentId;
    await _runGuarded(() async {
      _schedules = await _databaseService.fetchSchedulesForDepartment(departmentId);
      _events = _buildCalendarEvents();
    });
  }

  Future<void> refreshModules() async {
    final departmentId = _intern?.departmentId;
    await _runGuarded(() async {
      _modules = await _databaseService.fetchTrainingModulesForDepartment(departmentId);
    });
  }

  Future<void> refreshMarks() async {
    final intern = _intern;
    if (intern == null) return;

    await _runGuarded(() async {
      _marks = await _databaseService.fetchInternSkillMarks(intern.id);
      _events = _buildCalendarEvents();
    });
  }

  List<CalendarEventModel> _buildCalendarEvents() {
    final scheduleEvents = _schedules.map(
      (s) => CalendarEventModel(
        id: s.id,
        date: s.validFrom,
        title: 'Schedule starts: ${s.title}',
        description: s.department,
      ),
    );

    final markEvents = _marks.map(
      (m) => CalendarEventModel(
        id: m.id,
        date: m.evaluatedAt,
        title: 'Evaluation: ${m.skillName}',
        description: 'Mark ${m.mark.toStringAsFixed(2)} / 20',
      ),
    );

    return [...scheduleEvents, ...markEvents]
      ..sort((a, b) => a.date.compareTo(b.date));
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

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
