class JsonUtils {
  const JsonUtils._();

  static DateTime? dateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static DateTime dateTimeOrNow(dynamic value) {
    return dateTime(value) ?? DateTime.now();
  }

  static double toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static bool toBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
      if (normalized == '1') return true;
      if (normalized == '0') return false;
    }
    return fallback;
  }
}
