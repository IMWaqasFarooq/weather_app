import 'package:intl/intl.dart';

// Date/time formatting helpers used by the forecast widgets.
class DateFormatter {
  const DateFormatter._();

  static String hour(DateTime time) => DateFormat.j().format(time);

  static String weekday(DateTime time) => DateFormat.EEEE().format(time);

  static String shortWeekday(DateTime time) => DateFormat.E().format(time);

  static String time(DateTime time) => DateFormat.jm().format(time);

  static String fullDate(DateTime time) => DateFormat.yMMMMEEEEd().format(time);

  static bool isToday(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }

  static bool isSameHour(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour;
}
