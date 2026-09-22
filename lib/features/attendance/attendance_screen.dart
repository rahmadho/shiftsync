import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/location_utils.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';
import 'hold_to_record_button.dart';

/// S4 — Attendance (active check-in).
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  bool _simulateInside = true;

  static const _insideLat = -0.9373786051614612 + 0.00027; // ~30 m
  static const _insideLng = 100.36028655141162;
  static const _outsideLat = -0.9373786051614612 + 0.00225; // ~250 m
  static const _outsideLng = 100.36028655141162;

  double get _curLat => _simulateInside ? _insideLat : _outsideLat;
  double get _curLng => _simulateInside ? _insideLng : _outsideLng;

  void _onRecorded() {
    final geo = LocationUtils.check(_curLat, _curLng);
    final now = DateTime.now();
    final notifier = ref.read(todayAttendanceProvider.notifier);
    final today = ref.read(todayAttendanceProvider);

    if (!geo.isInside) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.absentFg,
          content: Text(
            '${ref.tr('geoFailMsg')} (${LocationUtils.formatDistance(geo.distanceMeters)}, '
            'max ${LocationUtils.radiusMeters.round()} m).',
          ),
        ),
      );
      return;
    }

    if (!today.hasCheckedIn) {
      notifier.checkIn(now);
    } else if (!today.hasCheckedOut) {
      notifier.checkOut(now);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.approvedFg,
        content: Text(
          '${ref.tr('geoSuccessMsg')} (${LocationUtils.formatDistance(geo.distanceMeters)}).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shift = ref.watch(upcomingShiftProvider);
    final today = ref.watch(todayAttendanceProvider);
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final geo = LocationUtils.check(_curLat, _curLng);
    final lang = ref.watch(localeProvider);

    final holdLabel = today.hasCheckedOut
        ? ref.tr('attendanceDoneToday')
        : today.hasCheckedIn
            ? ref.tr('holdToCheckOut')
            : ref.tr('holdToCheckIn');

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr('attendance')),
        actions: [
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
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  const Text('Headquarters', style: AppTextStyles.bodySm),
                  const Spacer(),
                  Text(AppDateFormatter.dayMonth(now, lang),
                      style: AppTextStyles.bodySm),
                ],
              ),
              const SizedBox(height: 24),

              Text(AppDateFormatter.hhmmAmPm(now),
                  style: AppTextStyles.display.copyWith(fontSize: 44)),
              const SizedBox(height: 8),
              const Text('Headquarters - Bldg A',
                  style: AppTextStyles.bodySm),
              const SizedBox(height: 8),

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
                      geo.isInside ? ref.tr('withinGeofence') : ref.tr('outsideGeofence'),
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

              HoldToRecordButton(
                onComplete: _onRecorded,
                label: ref.tr('holdToRecord'),
                recordedLabel: ref.tr('recorded'),
              ),
              const SizedBox(height: 12),
              Text(
                holdLabel,
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _TimeCard(
                      label: ref.tr('labelCheckIn'),
                      icon: Icons.login,
                      time: today.checkInAt,
                      color: AppColors.primary,
                      emptyLabel: ref.tr('notCheckedInYet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeCard(
                      label: ref.tr('labelCheckOut'),
                      icon: Icons.logout,
                      time: today.checkOutAt,
                      color: AppColors.lateFg,
                      emptyLabel: ref.tr('notCheckedInYet'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ref.tr('shift'),
                              style: AppTextStyles.caption
                                  .copyWith(letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            '${AppDateFormatter.hhmm(shift.startAt)} - '
                            '${AppDateFormatter.hhmm(shift.endAt)}  ·  '
                            '${ref.tr('standardShift')}',
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
    required this.emptyLabel,
  });

  final String label;
  final IconData icon;
  final DateTime? time;
  final Color color;
  final String emptyLabel;

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
          Text(time != null ? AppDateFormatter.hhmmAmPm(time!) : emptyLabel,
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
