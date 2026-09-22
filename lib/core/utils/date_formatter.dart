import 'package:intl/intl.dart';

/// Date/time formatting helpers (locale en_US to match the design copy).
abstract final class AppDateFormatter {
  AppDateFormatter._();

  static const _monthYear = 'MMMM yyyy';
  static const _dayMonth = 'EEE, MMM d';

  /// "October 2023"
  static String monthLabel(DateTime d) => DateFormat(_monthYear).format(d);

  /// "Tue, Oct 24"
  static String dayMonth(DateTime d) => DateFormat(_dayMonth).format(d);

  /// "Oct 24"
  static String shortDate(DateTime d) => DateFormat('MMM d').format(d);

  /// "08:55" (24h) — used for check-in/out times.
  static String hhmm(DateTime d) => DateFormat('HH:mm').format(d);

  /// "08:55 AM"
  static String hhmmAmPm(DateTime d) => DateFormat('hh:mm a').format(d);

  /// "07:55 AM | Mon, 24 Oct"
  static String clockLine(DateTime d) =>
      '${hhmmAmPm(d)} | ${DateFormat('EEE, d MMM').format(d)}';

  /// "WEEK OF OCT 23 - 29" for the week containing [d] (Mon–Sun).
  static String weekRangeLabel(DateTime d) {
    final monday = d.subtract(Duration(days: d.weekday - DateTime.monday));
    final sunday = monday.add(const Duration(days: 6));
    final month = DateFormat('MMM').format(monday).toUpperCase();
    final monDay = monday.day;
    final sunDay = sunday.day;
    if (monday.month == sunday.month) {
      return 'WEEK OF $month $monDay - $sunDay';
    }
    final endMonth = DateFormat('MMM').format(sunday).toUpperCase();
    return 'WEEK OF $month $monDay - $endMonth $sunDay';
  }

  /// Inclusive day count between two dates (Oct 5 → Oct 8 = 4).
  static int inclusiveDays(DateTime start, DateTime end) =>
      end.difference(start).inDays + 1;

  /// Weekday initials row S M T W T F S.
  static const List<String> weekdayInitials = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
}
