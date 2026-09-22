import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/security/location_service.dart';
import '../core/security/security_service.dart';

/// Device integrity scan (root/jailbreak/emulator + office WiFi).
/// Call `refresh()` to re-run the scan.
class IntegrityNotifier extends StateNotifier<AsyncValue<IntegrityReport>> {
  IntegrityNotifier() : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => SecurityService.instance.scan(),
    );
  }
}

final integrityProvider =
    StateNotifierProvider<IntegrityNotifier, AsyncValue<IntegrityReport>>(
  (ref) => IntegrityNotifier(),
);

/// Whether the attendance screen is using real GPS (device) or the
/// simulated fallback (web / unsupported platforms).
final useRealGpsProvider = Provider<bool>((ref) => true);

/// Latest GPS reading with mock-location flag (Phase 1).
final geoReadingProvider =
    FutureProvider.autoDispose<GeoReading>((ref) async {
  return LocationService.instance.getCurrent();
});
