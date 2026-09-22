import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shiftsync/core/localization/app_strings.dart';
import 'package:shiftsync/core/security/location_service.dart';
import 'package:shiftsync/core/security/security_service.dart';
import 'package:shiftsync/core/theme/app_colors.dart';
import 'package:shiftsync/core/utils/date_formatter.dart';
import 'package:shiftsync/core/utils/location_utils.dart';
import 'package:shiftsync/core/utils/validators.dart';
import 'package:shiftsync/data/mock/mock_data.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en_US', null);
  });
  group('Localization AppStrings', () {
    test('tr returns english by default', () {
      expect(AppStrings.tr('welcomeBack', AppLanguage.en), 'Welcome Back');
      expect(AppStrings.tr('navHome', AppLanguage.en), 'Home');
      expect(AppStrings.tr('holdToRecord', AppLanguage.en), 'Hold to record');
    });

    test('tr returns indonesian correctly', () {
      expect(AppStrings.tr('welcomeBack', AppLanguage.id), 'Selamat Datang Kembali');
      expect(AppStrings.tr('navHome', AppLanguage.id), 'Beranda');
      expect(AppStrings.tr('holdToRecord', AppLanguage.id), 'Tahan untuk absen');
      expect(AppStrings.tr('language', AppLanguage.id), 'Bahasa');
    });

    test('fallback returns key when not found', () {
      expect(AppStrings.tr('non_existing_key', AppLanguage.en), 'non_existing_key');
    });
  });

  group('Validators.emailOrId (PRD 7.6)', () {
    test('rejects empty', () {
      expect(Validators.emailOrId('', AppLanguage.en), isNotNull);
      expect(Validators.emailOrId('', AppLanguage.id), contains('wajib diisi'));
    });
    test('accepts employee id', () =>
        expect(Validators.emailOrId('#EMP-2024-89'), isNull));
    test('accepts valid email', () =>
        expect(Validators.emailOrId('sarah@shiftsync.com'), isNull));
    test('rejects malformed', () =>
        expect(Validators.emailOrId('not-an-email'), isNotNull));
  });

  group('Validators.password', () {
    test('rejects < 6', () {
      expect(Validators.password('123', lang: AppLanguage.en), isNotNull);
      expect(Validators.password('123', lang: AppLanguage.id), contains('minimal'));
    });
    test('accepts >= 6', () => expect(Validators.password('123456'), isNull));
  });

  group('AppDateFormatter with locale (PRD 7.5)', () {
    test('inclusiveDays Oct 5 -> Oct 8 == 4', () {
      expect(
        AppDateFormatter.inclusiveDays(
            DateTime(2023, 10, 5), DateTime(2023, 10, 8)),
        4,
      );
    });
    test('weekRangeLabel Oct 24 en vs id', () {
      expect(AppDateFormatter.weekRangeLabel(DateTime(2023, 10, 24), AppLanguage.en),
          'WEEK OF OCT 23 - 29');
      expect(AppDateFormatter.weekRangeLabel(DateTime(2023, 10, 24), AppLanguage.id),
          'MINGGU 23 - 29 OKT');
    });
    test('monthLabel Oct 2023 en vs id', () {
      expect(AppDateFormatter.monthLabel(DateTime(2023, 10), AppLanguage.en), 'October 2023');
      expect(AppDateFormatter.monthLabel(DateTime(2023, 10), AppLanguage.id), 'Oktober 2023');
    });
  });

  group('LocationUtils geofence (PRD 7.2)', () {
    test('office centre is inside (0 m)', () {
      final r = LocationUtils.check(
          LocationUtils.officeLat, LocationUtils.officeLng);
      expect(r.distanceMeters, lessThan(1));
      expect(r.isInside, isTrue);
    });
    test('~30 m north is inside', () {
      final r = LocationUtils.check(
          LocationUtils.officeLat + 0.00027, LocationUtils.officeLng);
      expect(r.isInside, isTrue);
    });
    test('~250 m north is OUTSIDE', () {
      final r = LocationUtils.check(
          LocationUtils.officeLat + 0.00225, LocationUtils.officeLng);
      expect(r.isInside, isFalse);
      expect(r.distanceMeters, greaterThan(LocationUtils.radiusMeters));
    });
    test('formatDistance rounds meters', () {
      expect(LocationUtils.formatDistance(45.6), '46 m');
      expect(LocationUtils.formatDistance(1250), '1.3 km');
    });
  });

  group('MockData per-month (History/Statistics filter)', () {
    test('October summary present == 20', () {
      expect(MockData.summaryFor(DateTime(2023, 10)).present, 20);
    });
    test('September summary present == 18', () {
      expect(MockData.summaryFor(DateTime(2023, 9)).present, 18);
    });
    test('unknown month returns zeroed summary', () {
      final s = MockData.summaryFor(DateTime(2023, 7));
      expect(s.present, 0);
      expect(s.ratio, 0);
    });
    test('history contains entries for Oct, Sep and Aug', () {
      final h = MockData.history();
      expect(h.any((a) => a.date.month == 10), isTrue);
      expect(h.any((a) => a.date.month == 9), isTrue);
      expect(h.any((a) => a.date.month == 8), isTrue);
    });
  });

  group('IntegrityReport anti-fraud logic (Phase 1 + 2)', () {
    test('clean device with office wifi does not block', () {
      const r = IntegrityReport(hasOfficeWifi: true);
      expect(r.blocksAttendance, isFalse);
      expect(r.level, ThreatLevel.none);
      expect(r.reasons, isEmpty);
    });

    test('mock location blocks attendance', () {
      const r = IntegrityReport(
          isMockLocationEnabled: true, hasOfficeWifi: true);
      expect(r.blocksAttendance, isTrue);
      expect(r.level, ThreatLevel.critical);
      expect(r.reasons, contains('mockLocation'));
    });

    test('rooted device blocks attendance', () {
      const r = IntegrityReport(isRooted: true, hasOfficeWifi: true);
      expect(r.blocksAttendance, isTrue);
      expect(r.reasons, contains('rooted'));
    });

    test('jailbroken device blocks attendance', () {
      const r = IntegrityReport(isJailbroken: true, hasOfficeWifi: true);
      expect(r.blocksAttendance, isTrue);
      expect(r.reasons, contains('jailbroken'));
    });

    test('emulator blocks attendance', () {
      const r = IntegrityReport(isEmulator: true, hasOfficeWifi: true);
      expect(r.blocksAttendance, isTrue);
      expect(r.reasons, contains('emulator'));
    });

    test('no office wifi is a warning, not a block', () {
      const r = IntegrityReport(hasOfficeWifi: false);
      expect(r.blocksAttendance, isFalse);
      expect(r.level, ThreatLevel.warning);
      expect(r.reasons, contains('noOfficeWifi'));
    });

    test('developer mode is a warning only', () {
      const r = IntegrityReport(hasOfficeWifi: true, developerMode: true);
      expect(r.blocksAttendance, isFalse);
      expect(r.level, ThreatLevel.warning);
    });
  });

  group('GeoReading trust logic (Phase 1, PRD 7.2)', () {
    test('successful non-mocked reading is trusted', () {
      const r = GeoReading(
        status: LocationStatus.success,
        latitude: LocationUtils.officeLat,
        longitude: LocationUtils.officeLng,
        isInside: true,
      );
      expect(r.hasFix, isTrue);
      expect(r.isTrusted, isTrue);
    });

    test('mocked reading is NOT trusted', () {
      const r = GeoReading(status: LocationStatus.success, isMocked: true);
      expect(r.isTrusted, isFalse);
    });

    test('permission denied has no fix', () {
      const r = GeoReading(status: LocationStatus.permissionDenied);
      expect(r.hasFix, isFalse);
      expect(r.isTrusted, isFalse);
    });
  });

  group('Security localization strings', () {
    test('security strings exist in both languages', () {
      for (final key in [
        'secMockLocation',
        'secRooted',
        'secJailbroken',
        'secEmulator',
        'secNoOfficeWifi',
        'secVerified',
      ]) {
        expect(AppStrings.tr(key, AppLanguage.en), isNot(key));
        expect(AppStrings.tr(key, AppLanguage.id), isNot(key));
      }
    });
  });

  test('On-time status is blue (PRD 2.2)', () {
    expect(AppColors.onTime, AppColors.primary);
    expect(AppColors.primary, const Color(0xFF2A8CED));
  });
}
