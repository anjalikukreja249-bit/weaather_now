import 'package:intl/intl.dart';

class WeatherDateUtils {
  WeatherDateUtils._();

  /// e.g. "Monday, 29 Jul"
  static String formatFullDate(DateTime date) =>
      DateFormat('EEEE, d MMM').format(date);

  /// e.g. "Mon"
  static String formatWeekday(DateTime date) =>
      DateFormat('EEE').format(date);

  /// e.g. "14:30"
  static String formatTime(DateTime date) =>
      DateFormat('HH:mm').format(date);

  /// e.g. "29 Jul 2025"
  static String formatShortDate(DateTime date) =>
      DateFormat('d MMM yyyy').format(date);

  /// Converts a Unix timestamp (seconds) to a local [DateTime].
  static DateTime fromUnix(int unixSeconds) =>
      DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);

  /// Returns `true` if [date] is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
