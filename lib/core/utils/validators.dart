/// Form validators per PRD 7.6. Return null when valid, else an error message.
abstract final class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final RegExp _employeeIdRegex = RegExp(r'^#EMP-\d{4}-\d{2}$');

  /// Email OR employee id (#EMP-2024-89).
  static String? emailOrId(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email or Employee ID is required';
    if (_employeeIdRegex.hasMatch(v)) return null;
    if (_emailRegex.hasMatch(v)) return null;
    return 'Enter a valid email or Employee ID (#EMP-YYYY-XX)';
  }

  static String? password(String? value, {int minLength = 6}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }
}
