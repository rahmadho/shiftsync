import '../localization/app_strings.dart';

/// Form validators per PRD 7.6.
abstract final class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final RegExp _employeeIdRegex = RegExp(r'^#EMP-\d{4}-\d{2}$');

  static String? emailOrId(String? value, [AppLanguage lang = AppLanguage.en]) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return lang == AppLanguage.id
          ? 'Email atau ID Karyawan wajib diisi'
          : 'Email or Employee ID is required';
    }
    if (_employeeIdRegex.hasMatch(v)) return null;
    if (_emailRegex.hasMatch(v)) return null;
    return lang == AppLanguage.id
        ? 'Masukkan email atau ID Karyawan (#EMP-YYYY-XX) yang valid'
        : 'Enter a valid email or Employee ID (#EMP-YYYY-XX)';
  }

  static String? password(String? value, {int minLength = 6, AppLanguage lang = AppLanguage.en}) {
    final v = value ?? '';
    if (v.isEmpty) {
      return lang == AppLanguage.id
          ? 'Kata sandi wajib diisi'
          : 'Password is required';
    }
    if (v.length < minLength) {
      return lang == AppLanguage.id
          ? 'Kata sandi minimal $minLength karakter'
          : 'Password must be at least $minLength characters';
    }
    return null;
  }
}
