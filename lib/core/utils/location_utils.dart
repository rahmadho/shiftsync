import 'dart:math' as math;

/// Result of a geofence distance check.
class GeofenceResult {
  const GeofenceResult({required this.distanceMeters, required this.isInside});

  final double distanceMeters;
  final bool isInside;
}

/// Location / geofence helpers (PRD 7.2).
abstract final class LocationUtils {
  LocationUtils._();

  /// Office geofence center (per user input).
  static const double officeLat = -0.9373786051614612;
  static const double officeLng = 100.36028655141162;

  /// Allowed radius in meters.
  static const double radiusMeters = 100;

  /// Haversine distance between two lat/lng points, in meters.
  static double distanceMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371000.0; // meters
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Check whether a point is inside the office geofence.
  static GeofenceResult check(double lat, double lng) {
    final d = distanceMeters(lat, lng, officeLat, officeLng);
    return GeofenceResult(distanceMeters: d, isInside: d <= radiusMeters);
  }

  /// Human-readable distance, e.g. "45 m" or "1.2 km".
  static String formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
}
