import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static String short(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  static String weekday(DateTime date) => DateFormat('EEEE, dd MMM').format(date);
}
