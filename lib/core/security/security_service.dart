import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'native_integrity.dart';

/// Severity of a detected integrity issue.
enum ThreatLevel { none, warning, critical }

/// Result of a device-integrity scan.
class IntegrityReport {
  const IntegrityReport({
    this.isRooted = false,
    this.isJailbroken = false,
    this.isEmulator = false,
    this.developerMode = false,
    this.isMockLocationEnabled = false,
    this.hasOfficeWifi = false,
    this.currentSsid,
    this.currentBssid,
    this.scanFailed = false,
  });

  final bool isRooted;
  final bool isJailbroken;
  final bool isEmulator;

  /// Android "Developer options" is enabled (advisory only, not blocking).
  final bool developerMode;
  final bool isMockLocationEnabled;
  final bool hasOfficeWifi;
  final String? currentSsid;
  final String? currentBssid;

  /// True when the scan itself could not run (e.g. unsupported platform).
  final bool scanFailed;

  /// Blocking conditions: mock location, root, jailbreak, or emulator.
  bool get isCompromised => isRooted || isJailbroken || isEmulator;

  bool get blocksAttendance => isMockLocationEnabled || isCompromised;

  ThreatLevel get level {
    if (blocksAttendance) return ThreatLevel.critical;
    if (developerMode || !hasOfficeWifi) return ThreatLevel.warning;
    return ThreatLevel.none;
  }

  List<String> get reasons {
    final list = <String>[];
    if (isMockLocationEnabled) list.add('mockLocation');
    if (isRooted) list.add('rooted');
    if (isJailbroken) list.add('jailbroken');
    if (isEmulator) list.add('emulator');
    if (developerMode) list.add('developerMode');
    if (!hasOfficeWifi) list.add('noOfficeWifi');
    return list;
  }
}

/// Phase 1 + Phase 2 anti-fraud device & network checks.
///
/// Phase 1 — mock-location detection is handled where the [Position] is read
///           (see `location_service.dart`, `Position.isMocked`).
/// Phase 2 — root/jailbreak, emulator, and office-WiFi (BSSID) checks live here.
class SecurityService {
  SecurityService._();
  static final SecurityService instance = SecurityService._();

  /// BSSID of the office router (lower-case, colon-separated).
  /// Leave null to skip the WiFi requirement (e.g. in mock/web mode).
  static const String? officeBssid = null;

  /// SSID of the office network (fallback when BSSID is unavailable).
  static const String? officeSsid = null;

  Future<IntegrityReport> scan({
    bool checkMockLocation = false,
  }) async {
    // Web has no native integrity APIs — return a neutral report.
    if (kIsWeb) {
      return const IntegrityReport(hasOfficeWifi: true);
    }

    var isRooted = false;
    var isJailbroken = false;
    var developerMode = false;
    var isEmulator = false;

    try {
      if (Platform.isAndroid) {
        isRooted = await NativeIntegrity.isRooted();
        developerMode = await NativeIntegrity.isDeveloperMode();
        isEmulator = await NativeIntegrity.isEmulator();
      } else if (Platform.isIOS) {
        isJailbroken = await NativeIntegrity.isJailbroken();
        isEmulator = await NativeIntegrity.isEmulator();
      }
    } catch (_) {
      // Native channel unavailable — treat as non-fatal.
    }

    String? ssid;
    String? bssid;
    var hasOfficeWifi = officeBssid == null && officeSsid == null;
    try {
      final info = NetworkInfo();
      ssid = await info.getWifiName();
      bssid = await info.getWifiBSSID();
      if (officeBssid != null || officeSsid != null) {
        final b = bssid?.toLowerCase();
        hasOfficeWifi =
            (officeBssid != null && b == officeBssid!.toLowerCase()) ||
                (officeSsid != null && _cleanSsid(ssid) == officeSsid);
      }
    } catch (_) {
      hasOfficeWifi = officeBssid == null && officeSsid == null;
    }

    return IntegrityReport(
      isRooted: isRooted,
      isJailbroken: isJailbroken,
      isEmulator: isEmulator,
      developerMode: developerMode,
      hasOfficeWifi: hasOfficeWifi,
      currentSsid: _cleanSsid(ssid),
      currentBssid: bssid,
    );
  }

  /// Removes surrounding quotes that Android/network_info_plus may add.
  static String? _cleanSsid(String? raw) {
    if (raw == null) return null;
    var s = raw.trim();
    if (s.startsWith('"') && s.endsWith('"') && s.length >= 2) {
      s = s.substring(1, s.length - 1);
    }
    return s.isEmpty ? null : s;
  }
}
