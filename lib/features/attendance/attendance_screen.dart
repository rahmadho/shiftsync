import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/location_utils.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';
import 'hold_to_record_button.dart';

/// S4 — Attendance (active check-in). Opened from Home.
///
/// Note: real GPS is not wired yet. A simulated current position is used so the
/// geofence logic (100 m radius around the office point) can be demonstrated.
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  // Simulated device position. Toggle via the switch in the app bar:
  // inside  -> ~30 m from office (within radius)
  // outside -> ~250 m from office (outside radius)
  bool _simulateInside = true;

  static const _insideLat = -0.9373786051614612 + 0.00027; // ~30 m north
  static const _insideLng = 100.36028655141162;
  static const _outsideLat = -0.9373786051614612 + 0.00225; // ~250 m north
  static const _outsideLng = 100.36028655141162;

  double get _curLat => _simulateInside ? _insideLat : _outsideLat;
  double get _curLng => _simulateInside ? _insideLng : _outsideLng;

  void _onRecorded() {
    final geo = LocationUtils.check(_curLat, _curLng);
    final now = DateTime.now();
    final notifier = ref.read(todayAttendanceProvider.notifier);
    final today = ref.read(todayAttendanceProvider);

    if (!geo.isInside) {
      // Outside radius -> FAILED
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.absentFg,
          content: Text(
            'Gagal: Anda di luar radius (${LocationUtils.formatDistance(geo.distanceMeters)} '
            'dari titik absen, maks ${LocationUtils.radiusMeters.round()} m).',
          ),
        ),
      );
      return;
    }

    // Inside radius -> SUCCESS
    if (!today.hasCheckedIn) {
      notifier.checkIn(now);
    } else if (!today.hasCheckedOut) {
      notifier.checkOut(now);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.approvedFg,
        content: Text(
          'Berhasil: absen tercatat (${LocationUtils.formatDistance(geo.distanceMeters)} '
          'dalam radius).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shift = ref.watch(upcomingShiftProvider);
    final today = ref.watch(todayAttendanceProvider);
    // Live clock following the device.
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final geo = LocationUtils.check(_curLat, _curLng);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          // Demo switch to simulate being inside/outside the geofence.
          Row(
            children: [
              Text(_simulateInside ? 'In' : 'Out',
                  style: AppTextStyles.caption),
              Switch(
                value: _simulateInside,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _simulateInside = v),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            children: [
              // Location header
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  const Text('Headquarters', style: AppTextStyles.bodySm),
                  const Spacer(),
                  Text(AppDateFormatter.dayMonth(now),
                      style: AppTextStyles.bodySm),
                ],
              ),
              const SizedBox(height: 24),

              // Live ticking clock (follows device time)
              Text(AppDateFormatter.hhmmAmPm(now),
                  style: AppTextStyles.display.copyWith(fontSize: 44)),
              const SizedBox(height: 8),
              const Text('Headquarters - Bldg A',
                  style: AppTextStyles.bodySm),
              const SizedBox(height: 8),

              // Geofence status + distance
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: geo.isInside
                      ? AppColors.approvedBg
                      : AppColors.absentBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      geo.isInside
                          ? Icons.check_circle
                          : Icons.error_outline,
                      size: 14,
                      color: geo.isInside
                          ? AppColors.approvedFg
                          : AppColors.absentFg,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      geo.isInside ? 'Within geofence' : 'Outside geofence',
                      style: AppTextStyles.caption.copyWith(
                        color: geo.isInside
                            ? AppColors.approvedFg
                            : AppColors.absentFg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${LocationUtils.formatDistance(geo.distanceMeters)} '
                      '/ ${LocationUtils.radiusMeters.round()} m',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Hold to record
              HoldToRecordButton(onComplete: _onRecorded),
              const SizedBox(height: 12),
              Text(
                today.hasCheckedOut
                    ? 'Absen hari ini selesai'
                    : today.hasCheckedIn
                        ? 'Hold untuk Check Out'
                        : 'Hold untuk Check In',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 32),

              // Two cards: today's check-in (left) & check-out (right)
              Row(
                children: [
                  Expanded(
                    child: _TimeCard(
                      label: 'CHECK IN',
                      icon: Icons.login,
                      time: today.checkInAt,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeCard(
                      label: 'CHECK OUT',
                      icon: Icons.logout,
                      time: today.checkOutAt,
                      color: AppColors.lateFg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Shift info
              AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SHIFT',
                              style: AppTextStyles.caption
                                  .copyWith(letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            '${AppDateFormatter.hhmm(shift.startAt)} - '
                            '${AppDateFormatter.hhmm(shift.endAt)}  ·  '
                            'Standard Shift',
                            style: AppTextStyles.label,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.icon,
    required this.time,
    required this.color,
  });

  final String label;
  final IconData icon;
  final DateTime? time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTextStyles.caption.copyWith(letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            time != null ? AppDateFormatter.hhmm(time!) : '-- : --',
            style: AppTextStyles.h1.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 2),
          Text(time != null ? AppDateFormatter.hhmmAmPm(time!) : 'Belum absen',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
