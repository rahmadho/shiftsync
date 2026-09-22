import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';

/// S0 — My Statistics (opened from Profile).
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(attendanceSummaryProvider);
    final flags = ref.watch(flagsProvider);
    final ratioPct = (summary.ratio * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('My Statistics')),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                const Text('My Statistics', style: AppTextStyles.h2),
                const Spacer(),
                const Text('October 2023', style: AppTextStyles.bodySm),
              ],
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
                            Text('$ratioPct%',
                                style: AppTextStyles.h2),
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
                        _legend(context, 'Present',
                            '${summary.present} days', AppColors.primary),
                        const SizedBox(height: 6),
                        _legend(context, 'Late', '${summary.late} days',
                            AppColors.lateFg),
                        const SizedBox(height: 6),
                        _legend(context, 'Absent', '${summary.absent} days',
                            AppColors.absentFg),
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
                        Text('TOTAL HOURS',
                            style: AppTextStyles.caption
                                .copyWith(letterSpacing: 1)),
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
                        Text('OVERTIME',
                            style: AppTextStyles.caption
                                .copyWith(letterSpacing: 1)),
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
                      title: Text(flags[i].title,
                          style: AppTextStyles.label),
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

  Widget _legend(
      BuildContext context, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
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
