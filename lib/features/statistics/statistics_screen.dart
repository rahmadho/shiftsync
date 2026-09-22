import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/mock/mock_data.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';

/// S0 — My Statistics (opened from Profile). Supports month navigation.
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  DateTime _month = DateTime(2023, 10);

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final summary = MockData.summaryFor(_month);
    final flags = ref.watch(flagsProvider);
    final ratioPct = (summary.ratio * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('My Statistics')),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8,
              AppSizes.screenPadding, 24),
          children: [
            // Month selector
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _shiftMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                    color: AppColors.textPrimary,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(AppDateFormatter.monthLabel(_month),
                          style: AppTextStyles.label),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _shiftMonth(1),
                    icon: const Icon(Icons.chevron_right),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Attendance ratio ring
            AppCard(
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: CircularProgressIndicator(
                            value: summary.ratio,
                            strokeWidth: 9,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$ratioPct%', style: AppTextStyles.h2),
                            Text('Score', style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ATTENDANCE RATIO',
                            style: AppTextStyles.caption
                                .copyWith(letterSpacing: 1)),
                        const SizedBox(height: 12),
                        _legend('Present', '${summary.present} days',
                            AppColors.primary, Icons.check_circle_outline),
                        const SizedBox(height: 6),
                        _legend('Late', '${summary.late} days',
                            AppColors.lateFg, Icons.access_time),
                        const SizedBox(height: 6),
                        _legend('Absent', '${summary.absent} days',
                            AppColors.absentFg, Icons.cancel_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Total hours + overtime
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('TOTAL HOURS',
                                style: AppTextStyles.caption
                                    .copyWith(letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${summary.totalHours}h',
                            style: AppTextStyles.h1),
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
                        Row(
                          children: [
                            const Icon(Icons.more_time,
                                size: 14, color: AppColors.lateFg),
                            const SizedBox(width: 6),
                            Text('OVERTIME',
                                style: AppTextStyles.caption
                                    .copyWith(letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${summary.overtimeHours}h',
                            style: AppTextStyles.h1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Late & Early leave — shown in HOURS (not days), with icons
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: AppColors.lateFg),
                            const SizedBox(width: 6),
                            Text('TERLAMBAT',
                                style: AppTextStyles.caption
                                    .copyWith(letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${_fmt(summary.lateHours)} jam',
                            style: AppTextStyles.h1
                                .copyWith(color: AppColors.lateFg, fontSize: 22)),
                        const SizedBox(height: 2),
                        Text('Total keterlambatan',
                            style: AppTextStyles.caption),
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
                        Row(
                          children: [
                            const Icon(Icons.directions_run,
                                size: 14, color: AppColors.absentFg),
                            const SizedBox(width: 6),
                            Text('PULANG CEPAT',
                                style: AppTextStyles.caption
                                    .copyWith(letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${_fmt(summary.earlyLeaveHours)} jam',
                            style: AppTextStyles.h1.copyWith(
                                color: AppColors.absentFg, fontSize: 22)),
                        const SizedBox(height: 2),
                        Text('Total pulang cepat',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Encouragement banner
            AppCard(
              color: AppColors.onTimeBg,
              child: Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Great job!', style: AppTextStyles.label),
                        const SizedBox(height: 2),
                        Text(
                          'Your punctuality has improved by 5% compared to '
                          'last month. Keep it up!',
                          style: AppTextStyles.bodySm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Flags', style: AppTextStyles.h2),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All',
                      style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < flags.length; i++) ...[
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.background,
                        child: Text(
                          flags[i].occurredAt.day.toString().padLeft(2, '0'),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                      ),
                      title:
                          Text(flags[i].title, style: AppTextStyles.label),
                      subtitle: Text(flags[i].description,
                          style: AppTextStyles.caption),
                      trailing: Text(flags[i].deltaLabel,
                          style: AppTextStyles.caption),
                    ),
                    if (i != flags.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format hours without trailing .0 (e.g. 1.5 -> "1.5", 2.0 -> "2").
  static String _fmt(double h) =>
      h == h.roundToDouble() ? h.toInt().toString() : h.toString();

  Widget _legend(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodySm),
        const Spacer(),
        Text(value,
            style:
                AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
