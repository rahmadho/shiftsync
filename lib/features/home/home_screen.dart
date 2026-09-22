import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/mock/mock_data.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';

/// S2 — Home Dashboard.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    final shift = ref.watch(upcomingShiftProvider);
    final summary = ref.watch(attendanceSummaryProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding, 12, AppSizes.screenPadding, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, ${MockData.homeUserName}',
                            style: AppTextStyles.h1),
                        const SizedBox(height: 4),
                        Text(
                          AppDateFormatter.clockLine(_now),
                          style: AppTextStyles.bodySm,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.onTimeBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none,
                        color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Upcoming shift card
              AppCard(
                color: AppColors.primary,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 16, color: Colors.white.withValues(alpha: .8)),
                        const SizedBox(width: 6),
                        Text('UPCOMING SHIFT',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: .8),
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(shift.title,
                        style: AppTextStyles.h2
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      '${AppDateFormatter.hhmm(shift.startAt)} - '
                      '${AppDateFormatter.hhmm(shift.endAt)}',
                      style: AppTextStyles.body
                          .copyWith(color: Colors.white.withValues(alpha: .95)),
                    ),
                    const SizedBox(height: 4),
                    Text(shift.locationName,
                        style: AppTextStyles.bodySm
                            .copyWith(color: Colors.white.withValues(alpha: .8))),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Check in/out
              AppCard(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.approvedBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('ON TIME',
                          style: TextStyle(
                            color: AppColors.approvedFg,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: .5,
                          )),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push('/attendance'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            icon: const Icon(Icons.login, size: 18),
                            label: const Text('Check In'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/attendance'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: const BorderSide(color: AppColors.border),
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusButton),
                              ),
                            ),
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text('Check Out'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.approvedFg),
                        const SizedBox(width: 4),
                        Text(
                          'You are currently within the geolocation range.',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.approvedFg),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Monthly overview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Monthly Overview', style: AppTextStyles.h2),
                  TextButton(
                    onPressed: () => context.go('/history'),
                    child: const Text('View All',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatTile(
                      value: '${summary.present}',
                      label: 'Present',
                      color: AppColors.primary),
                  const SizedBox(width: 12),
                  _StatTile(
                      value: '${summary.late}',
                      label: 'Late',
                      color: AppColors.lateFg),
                  const SizedBox(width: 12),
                  _StatTile(
                      value: '${summary.absent}',
                      label: 'Absent',
                      color: AppColors.absentFg),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.h1.copyWith(color: color, fontSize: 28)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySm),
          ],
        ),
      ),
    );
  }
}
