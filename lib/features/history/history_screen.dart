import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/attendance.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

/// S3 — Attendance History.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(attendanceSummaryProvider);
    final history = ref.watch(attendanceHistoryProvider);

    // Group by ISO week start (Monday).
    final groups = <DateTime, List<Attendance>>{};
    for (final a in history) {
      final monday =
          a.date.subtract(Duration(days: a.date.weekday - DateTime.monday));
      groups.putIfAbsent(_day(monday), () => []).add(a);
    }
    final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text('October 2023', style: AppTextStyles.bodySm),
            const SizedBox(height: 12),
            Row(
              children: [
                _SummaryCard(
                    value: summary.present,
                    label: 'Present',
                    color: AppColors.primary),
                const SizedBox(width: 12),
                _SummaryCard(
                    value: summary.late,
                    label: 'Late',
                    color: AppColors.lateFg),
                const SizedBox(width: 12),
                _SummaryCard(
                    value: summary.absent,
                    label: 'Absent',
                    color: AppColors.absentFg),
              ],
            ),
            const SizedBox(height: 24),
            for (final k in keys) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  AppDateFormatter.weekRangeLabel(k),
                  style: AppTextStyles.caption.copyWith(
                      letterSpacing: 1, fontWeight: FontWeight.w600),
                ),
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < groups[k]!.length; i++) ...[
                      _AttendanceRow(entry: groups[k]![i]),
                      if (i != groups[k]!.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text('$value',
                style: AppTextStyles.h1.copyWith(color: color, fontSize: 26)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.entry});

  final Attendance entry;

  BadgeStatus get _badge => switch (entry.status) {
        AttendanceStatus.onTime => BadgeStatus.onTime,
        AttendanceStatus.late => BadgeStatus.late,
        AttendanceStatus.absent => BadgeStatus.absent,
      };

  @override
  Widget build(BuildContext context) {
    final hasTimes = entry.checkInAt != null && entry.checkOutAt != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppDateFormatter.dayMonth(entry.date),
                    style: AppTextStyles.label),
                const SizedBox(height: 6),
                StatusBadge(status: _badge),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _Time(
                      value: hasTimes
                          ? AppDateFormatter.hhmm(entry.checkInAt!)
                          : '-- : --',
                      caption: hasTimes ? 'AM' : ''),
                  const SizedBox(width: 14),
                  _Time(
                      value: hasTimes
                          ? AppDateFormatter.hhmm(entry.checkOutAt!)
                          : '-- : --',
                      caption: hasTimes ? 'PM' : ''),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Time extends StatelessWidget {
  const _Time({required this.value, required this.caption});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: AppTextStyles.label),
        if (caption.isNotEmpty)
          Text(caption,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
