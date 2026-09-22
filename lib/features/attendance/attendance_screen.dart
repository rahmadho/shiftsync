import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';
import 'hold_to_record_button.dart';

/// S4 — Attendance (active check-in). Opened from Home.
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onRecorded() {
    setState(() => _recorded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance recorded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shift = ref.watch(upcomingShiftProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  const Text('Headquarters', style: AppTextStyles.bodySm),
                  const Spacer(),
                  Text(AppDateFormatter.dayMonth(_now),
                      style: AppTextStyles.bodySm),
                ],
              ),
              const SizedBox(height: 24),
              Text(AppDateFormatter.hhmmAmPm(_now),
                  style: AppTextStyles.display.copyWith(fontSize: 44)),
              const SizedBox(height: 8),
              Text(
                'Headquarters - Bldg A',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                      size: 14, color: AppColors.approvedFg),
                  const SizedBox(width: 4),
                  Text('Within geofence',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.approvedFg)),
                ],
              ),
              const SizedBox(height: 32),
              HoldToRecordButton(onComplete: _onRecorded),
              const SizedBox(height: 12),
              Text(
                _recorded
                    ? 'Recorded at ${AppDateFormatter.hhmmAmPm(_now)}'
                    : 'Hold to record',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SHIFT',
                              style: AppTextStyles.caption
                                  .copyWith(letterSpacing: 1)),
                          const SizedBox(height: 6),
                          Text(
                            '${AppDateFormatter.hhmm(shift.startAt)} - '
                            '${AppDateFormatter.hhmm(shift.endAt)}',
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: 2),
                          const Text('Standard Shift',
                              style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SCHEDULED',
                              style: AppTextStyles.caption
                                  .copyWith(letterSpacing: 1)),
                          const SizedBox(height: 6),
                          const Text('8h 00m', style: AppTextStyles.h2),
                          const SizedBox(height: 2),
                          const Text('Duration', style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
