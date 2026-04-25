class CalendarEventModel {
  const CalendarEventModel({
    required this.id,
    required this.date,
    required this.title,
    this.description,
  });

  final String id;
  final DateTime date;
  final String title;
  final String? description;
}
