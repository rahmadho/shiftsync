import 'dart:io';

import 'package:flutter/services.dart';

/// Native device-integrity checks (root / jailbreak / emulator).
///
/// Implemented via a MethodChannel instead of a third-party plugin so we
/// control the native code and avoid unmaintained dependencies that break
/// on newer Android Gradle Plugin versions.
class NativeIntegrity {
  NativeIntegrity._();
  static const MethodChannel _channel =
      MethodChannel('com.shiftsync.shiftsync/integrity');

  /// Returns true when the device shows signs of being rooted (Android).
  static Future<bool> isRooted() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isRooted') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Returns true when the device shows signs of being jailbroken (iOS).
  static Future<bool> isJailbroken() async {
    if (!Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod<bool>('isJailbroken') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Returns true when running inside an emulator/simulator.
  static Future<bool> isEmulator() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod<bool>('isEmulator') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Returns true when Android developer options are enabled.
  static Future<bool> isDeveloperMode() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isDeveloperMode') ?? false;
    } catch (_) {
      return false;
    }
  }
}
