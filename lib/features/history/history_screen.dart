import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/attendance.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

/// S3 — Attendance History (with month selector).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // Selected month (starts at October 2023, the design's month).
  DateTime _month = DateTime(2023, 10);

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final allHistory = ref.watch(attendanceHistoryProvider);

    // Filter entries by selected month.
    final history = allHistory
        .where((a) => a.date.year == _month.year && a.date.month == _month.month)
        .toList();

    // Summary for the month.
    final present = history.where((a) => a.status == AttendanceStatus.onTime).length;
    final late = history.where((a) => a.status == AttendanceStatus.late).length;
    final absent = history.where((a) => a.status == AttendanceStatus.absent).length;

    // Group by ISO week (Monday).
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
            // Month selector
            _MonthSelector(
              label: AppDateFormatter.monthLabel(_month),
              onPrev: () => _shiftMonth(-1),
              onNext: () => _shiftMonth(1),
            ),
            const SizedBox(height: 16),

            // Recap: label on top, number, "Days" below
            Row(
              children: [
                _RecapCard(
                    label: 'Present', value: present, color: AppColors.primary),
                const SizedBox(width: 12),
                _RecapCard(
                    label: 'Late', value: late, color: AppColors.lateFg),
                const SizedBox(width: 12),
                _RecapCard(
                    label: 'Absent', value: absent, color: AppColors.absentFg),
              ],
            ),
            const SizedBox(height: 24),

            if (history.isEmpty)
              _EmptyState(month: AppDateFormatter.monthLabel(_month))
            else
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

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Center(
              child: Text(label, style: AppTextStyles.label),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

/// Recap card: label on top, big number, "Days" below.
class _RecapCard extends StatelessWidget {
  const _RecapCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Text('$value',
                style: AppTextStyles.h1.copyWith(color: color, fontSize: 26)),
            const SizedBox(height: 2),
            Text('Days', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.month});

  final String month;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.event_busy_outlined,
              size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('Tidak ada data absensi',
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text('Belum ada catatan untuk $month',
              style: AppTextStyles.caption),
        ],
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
