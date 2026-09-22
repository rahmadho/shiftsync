import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/mock/mock_data.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';

/// S0 — My Statistics (opened from Profile).
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
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.tr('myStatistics'))),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 24),
          children: [
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
                      child: Text(AppDateFormatter.monthLabel(_month, lang),
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
                            Text(ref.tr('score'), style: AppTextStyles.caption),
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
                        Text(ref.tr('attendanceRatio'),
                            style: AppTextStyles.caption
                                .copyWith(letterSpacing: 1)),
                        const SizedBox(height: 12),
                        _legend(ref.tr('present'), '${summary.present} ${ref.tr('days')}',
                            AppColors.primary, Icons.check_circle_outline),
                        const SizedBox(height: 6),
                        _legend(ref.tr('late'), '${summary.late} ${ref.tr('days')}',
                            AppColors.lateFg, Icons.access_time),
                        const SizedBox(height: 6),
                        _legend(ref.tr('absent'), '${summary.absent} ${ref.tr('days')}',
                            AppColors.absentFg, Icons.cancel_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                            Text(ref.tr('totalHours'),
                                style: AppTextStyles.caption
                                    .copyWith(letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${summary.totalHours}${ref.tr('hoursUnit')}',
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
                            Text(ref.tr('overtime'),
                                style: AppTextStyles.caption
                                    .copyWith(letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${summary.overtimeHours}${ref.tr('hoursUnit')}',
                            style: AppTextStyles.h1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
                            Text(ref.tr('lateHoursLabel'),
                                style: AppTextStyles.caption
                                    .copyWith(letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${_fmt(summary.lateHours)} ${ref.tr('hoursWord')}',
                            style: AppTextStyles.h1
                                .copyWith(color: AppColors.lateFg, fontSize: 20)),
                        const SizedBox(height: 2),
                        Text(ref.tr('totalLateDesc'),
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
                            Text(ref.tr('earlyLeaveLabel'),
                                style: AppTextStyles.caption
                                    .copyWith(letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${_fmt(summary.earlyLeaveHours)} ${ref.tr('hoursWord')}',
                            style: AppTextStyles.h1.copyWith(
                                color: AppColors.absentFg, fontSize: 20)),
                        const SizedBox(height: 2),
                        Text(ref.tr('totalEarlyDesc'),
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
                        Text(ref.tr('greatJob'), style: AppTextStyles.label),
                        const SizedBox(height: 2),
                        Text(
                          ref.tr('encouragementMsg'),
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
                Text(ref.tr('recentFlags'), style: AppTextStyles.h2),
                TextButton(
                  onPressed: () {},
                  child: Text(ref.tr('viewAll'),
                      style: const TextStyle(color: AppColors.primary)),
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
