import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_strings.dart';
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
    final lang = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding, 12, AppSizes.screenPadding, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Header with avatar ----------
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.onTimeBg,
                      child: Icon(Icons.person,
                          size: 28, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${ref.tr('hello')}, ${MockData.homeUserName}',
                            style: AppTextStyles.h2),
                        const SizedBox(height: 2),
                        Text(
                          AppDateFormatter.clockLine(_now, lang),
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

              // ---------- Upcoming shift card ----------
              _UpcomingShiftCard(shift: shift),
              const SizedBox(height: 16),

              // ---------- Check in / out ----------
              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push('/attendance'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            icon: const Icon(Icons.login, size: 18),
                            label: Text(ref.tr('checkIn')),
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
                            label: Text(ref.tr('checkOut')),
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
                        Flexible(
                          child: Text(
                            ref.tr('withinGeofenceMsg'),
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.approvedFg),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ---------- Monthly overview ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ref.tr('monthlyOverview'), style: AppTextStyles.h2),
                  TextButton(
                    onPressed: () => context.go('/history'),
                    child: Text(ref.tr('viewAll'),
                        style: const TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatTile(
                      value: '${summary.present}',
                      label: ref.tr('present'),
                      icon: Icons.check_circle_outline,
                      color: AppColors.primary),
                  const SizedBox(width: 12),
                  _StatTile(
                      value: '${summary.late}',
                      label: ref.tr('late'),
                      icon: Icons.access_time,
                      color: AppColors.lateFg),
                  const SizedBox(width: 12),
                  _StatTile(
                      value: '${summary.absent}',
                      label: ref.tr('absent'),
                      icon: Icons.cancel_outlined,
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

class _UpcomingShiftCard extends ConsumerWidget {
  const _UpcomingShiftCard({required this.shift});

  final dynamic shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusCard),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule,
                    size: 16, color: Colors.white.withValues(alpha: .85)),
                const SizedBox(width: 6),
                Text(ref.tr('upcomingShift'),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: .85),
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    )),
                const Spacer(),
                Text(shift.title,
                    style: AppTextStyles.label.copyWith(color: Colors.white)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppSizes.radiusCard),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            '${AppDateFormatter.hhmm(shift.startAt)} - '
                            '${AppDateFormatter.hhmm(shift.endAt)}',
                            style: AppTextStyles.h2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(shift.locationName,
                                style: AppTextStyles.bodySm),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.approvedBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(ref.tr('statusOnTime').toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.approvedFg,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: .5,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.h1.copyWith(color: color, fontSize: 26)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
