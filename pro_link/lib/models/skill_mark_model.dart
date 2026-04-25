import '../utils/json_utils.dart';

class SkillMarkModel {
  const SkillMarkModel({
    required this.id,
    required this.internId,
    this.internName,
    required this.mentorId,
    this.mentorName,
    required this.skillName,
    required this.mark,
    this.comment,
    required this.evaluatedAt,
  });

  final String id;
  final String internId;
  final String? internName;
  final String mentorId;
  final String? mentorName;
  final String skillName;
  final double mark;
  final String? comment;
  final DateTime evaluatedAt;

  factory SkillMarkModel.fromMap(Map<String, dynamic> map) {
    final intern = map['intern'];
    final mentor = map['mentor'];

    return SkillMarkModel(
      id: map['id']?.toString() ?? '',
      internId: map['intern_id']?.toString() ?? '',
      internName: intern is Map<String, dynamic> ? intern['full_name']?.toString() : null,
      mentorId: map['mentor_id']?.toString() ?? '',
      mentorName: mentor is Map<String, dynamic> ? mentor['full_name']?.toString() : null,
      skillName: map['skill_name']?.toString() ?? '',
      mark: JsonUtils.toDouble(map['mark']),
      comment: map['comment']?.toString(),
      evaluatedAt: JsonUtils.dateTimeOrNow(map['evaluated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'intern_id': internId,
      'mentor_id': mentorId,
      'skill_name': skillName,
      'mark': mark,
      'comment': comment,
    };
  }
}
