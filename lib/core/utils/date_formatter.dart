import 'package:intl/intl.dart';
import '../localization/app_strings.dart';

/// Date/time formatting helpers supporting en and id locales.
abstract final class AppDateFormatter {
  AppDateFormatter._();

  static String _localeCode(AppLanguage lang) => lang == AppLanguage.id ? 'id_ID' : 'en_US';

  /// "October 2023" / "Oktober 2023"
  static String monthLabel(DateTime d, [AppLanguage lang = AppLanguage.en]) =>
      DateFormat('MMMM yyyy', _localeCode(lang)).format(d);

  /// "Tue, Oct 24" / "Sel, 24 Okt"
  static String dayMonth(DateTime d, [AppLanguage lang = AppLanguage.en]) =>
      DateFormat('EEE, MMM d', _localeCode(lang)).format(d);

  /// "Oct 24" / "24 Okt"
  static String shortDate(DateTime d, [AppLanguage lang = AppLanguage.en]) =>
      DateFormat('MMM d', _localeCode(lang)).format(d);

  /// "08:55" (24h)
  static String hhmm(DateTime d) => DateFormat('HH:mm').format(d);

  /// "08:55 AM"
  static String hhmmAmPm(DateTime d) => DateFormat('hh:mm a').format(d);

  /// "07:55 AM | Mon, 24 Oct"
  static String clockLine(DateTime d, [AppLanguage lang = AppLanguage.en]) =>
      '${hhmmAmPm(d)} | ${DateFormat('EEE, d MMM', _localeCode(lang)).format(d)}';

  /// "WEEK OF OCT 23 - 29" / "MINGGU 23 - 29 OKT"
  static String weekRangeLabel(DateTime d, [AppLanguage lang = AppLanguage.en]) {
    final monday = d.subtract(Duration(days: d.weekday - DateTime.monday));
    final sunday = monday.add(const Duration(days: 6));
    final locale = _localeCode(lang);
    final month = DateFormat('MMM', locale).format(monday).toUpperCase();
    final monDay = monday.day;
    final sunDay = sunday.day;

    if (lang == AppLanguage.id) {
      if (monday.month == sunday.month) {
        return 'MINGGU $monDay - $sunDay $month';
      }
      final endMonth = DateFormat('MMM', locale).format(sunday).toUpperCase();
      return 'MINGGU $monDay $month - $sunDay $endMonth';
    }

    if (monday.month == sunday.month) {
      return 'WEEK OF $month $monDay - $sunDay';
    }
    final endMonth = DateFormat('MMM', locale).format(sunday).toUpperCase();
    return 'WEEK OF $month $monDay - $endMonth $sunDay';
  }

  /// Inclusive day count between two dates (Oct 5 -> Oct 8 = 4).
  static int inclusiveDays(DateTime start, DateTime end) =>
      end.difference(start).inDays + 1;
}
