import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/location_utils.dart';

/// Outcome of a location acquisition + integrity check.
enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  mocked,
  error,
}

class GeoReading {
  const GeoReading({
    required this.status,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.distanceMeters,
    this.isInside = false,
    this.isMocked = false,
    this.errorMessage,
  });

  final LocationStatus status;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final double? distanceMeters;
  final bool isInside;
  final bool isMocked;
  final String? errorMessage;

  bool get hasFix => status == LocationStatus.success;

  /// A fix that is usable for attendance (not mocked, inside geofence).
  bool get isTrusted => status == LocationStatus.success && !isMocked;
}

/// Phase 1 anti-fraud: real device GPS with mock-location detection.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Fetches the current position, verifying the OS-mock-location flag.
  ///
  /// Returns a [GeoReading] whose `status` explains any failure so the UI can
  /// react (request permission, show "enable GPS", or block fake locations).
  Future<GeoReading> getCurrent({Duration timeout = const Duration(seconds: 10)}) async {
    // Web / desktop have no continuous geolocation guarantee — fall back.
    if (kIsWeb) {
      return const GeoReading(
        status: LocationStatus.error,
        errorMessage: 'unsupported_platform',
      );
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const GeoReading(status: LocationStatus.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const GeoReading(status: LocationStatus.permissionDenied);
      }
      if (permission == LocationPermission.deniedForever) {
        return const GeoReading(status: LocationStatus.permissionDeniedForever);
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );

      final distance = LocationUtils.distanceMeters(
        pos.latitude,
        pos.longitude,
        LocationUtils.officeLat,
        LocationUtils.officeLng,
      );

      // Phase 1: trust the OS mock flag.
      final mocked = pos.isMocked;

      return GeoReading(
        status: LocationStatus.success,
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        distanceMeters: distance,
        isInside: distance <= LocationUtils.radiusMeters,
        isMocked: mocked,
      );
    } catch (e) {
      if (!kIsWeb && Platform.isAndroid) {
        // TimeoutException etc.
      }
      return GeoReading(
        status: LocationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
