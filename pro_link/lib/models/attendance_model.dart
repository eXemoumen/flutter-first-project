import '../utils/json_utils.dart';

enum AttendanceStatus { present, absent, late, excused }

AttendanceStatus attendanceStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'present':
      return AttendanceStatus.present;
    case 'absent':
      return AttendanceStatus.absent;
    case 'late':
      return AttendanceStatus.late;
    case 'excused':
      return AttendanceStatus.excused;
    default:
      return AttendanceStatus.present;
  }
}

String attendanceStatusToString(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'present';
    case AttendanceStatus.absent:
      return 'absent';
    case AttendanceStatus.late:
      return 'late';
    case AttendanceStatus.excused:
      return 'excused';
  }
}

class AttendanceModel {
  const AttendanceModel({
    required this.id,
    required this.internId,
    this.internName,
    required this.mentorId,
    this.mentorName,
    required this.date,
    required this.status,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String internId;
  final String? internName;
  final String mentorId;
  final String? mentorName;
  final DateTime date;
  final AttendanceStatus status;
  final String? notes;
  final DateTime? createdAt;

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    final intern = map['intern'];
    final mentor = map['mentor'];

    return AttendanceModel(
      id: map['id']?.toString() ?? '',
      internId: map['intern_id']?.toString() ?? '',
      internName: intern is Map<String, dynamic> ? intern['full_name']?.toString() : null,
      mentorId: map['mentor_id']?.toString() ?? '',
      mentorName: mentor is Map<String, dynamic> ? mentor['full_name']?.toString() : null,
      date: JsonUtils.dateTimeOrNow(map['date']),
      status: attendanceStatusFromString(map['status']?.toString() ?? 'present'),
      notes: map['notes']?.toString(),
      createdAt: JsonUtils.dateTime(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'intern_id': internId,
      'mentor_id': mentorId,
      'date': date.toIso8601String().split('T').first,
      'status': attendanceStatusToString(status),
      'notes': notes,
    };
  }
}
