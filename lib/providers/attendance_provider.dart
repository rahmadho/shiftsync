import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today's attendance record (check-in / check-out times).
class TodayAttendance {
  const TodayAttendance({this.checkInAt, this.checkOutAt});

  final DateTime? checkInAt;
  final DateTime? checkOutAt;

  bool get hasCheckedIn => checkInAt != null;
  bool get hasCheckedOut => checkOutAt != null;

  TodayAttendance copyWith({DateTime? checkInAt, DateTime? checkOutAt}) =>
      TodayAttendance(
        checkInAt: checkInAt ?? this.checkInAt,
        checkOutAt: checkOutAt ?? this.checkOutAt,
      );
}

class TodayAttendanceNotifier extends StateNotifier<TodayAttendance> {
  TodayAttendanceNotifier() : super(const TodayAttendance());

  void checkIn(DateTime at) {
    if (state.hasCheckedIn) return;
    state = state.copyWith(checkInAt: at);
  }

  void checkOut(DateTime at) {
    if (!state.hasCheckedIn || state.hasCheckedOut) return;
    state = state.copyWith(checkOutAt: at);
  }
}

final todayAttendanceProvider =
    StateNotifierProvider<TodayAttendanceNotifier, TodayAttendance>(
  (ref) => TodayAttendanceNotifier(),
);

/// Ticking clock provider — updates every second so the UI follows the device.
final clockProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
