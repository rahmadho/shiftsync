import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftsync/core/theme/app_colors.dart';
import 'package:shiftsync/core/utils/validators.dart';
import 'package:shiftsync/core/utils/date_formatter.dart';

void main() {
  group('Validators.emailOrId (PRD 7.6)', () {
    test('rejects empty', () {
      expect(Validators.emailOrId(''), isNotNull);
    });
    test('accepts employee id #EMP-2024-89', () {
      expect(Validators.emailOrId('#EMP-2024-89'), isNull);
    });
    test('accepts valid email', () {
      expect(Validators.emailOrId('sarah@shiftsync.com'), isNull);
    });
    test('rejects malformed input', () {
      expect(Validators.emailOrId('not-an-email'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('rejects shorter than 6', () {
      expect(Validators.password('123'), isNotNull);
    });
    test('accepts 6+ chars', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('AppDateFormatter (PRD 7.5)', () {
    test('inclusiveDays Oct 5 -> Oct 8 == 4', () {
      expect(
        AppDateFormatter.inclusiveDays(
            DateTime(2023, 10, 5), DateTime(2023, 10, 8)),
        4,
      );
    });
    test('weekRangeLabel Oct 24 2023 -> WEEK OF OCT 23 - 29', () {
      expect(AppDateFormatter.weekRangeLabel(DateTime(2023, 10, 24)),
          'WEEK OF OCT 23 - 29');
    });
  });

  test('On-time status is blue (PRD 2.2)', () {
    expect(AppColors.onTime, AppColors.primary);
    expect(AppColors.primary, const Color(0xFF2A8CED));
  });
}
