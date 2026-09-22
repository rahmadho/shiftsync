import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_strings.dart';
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
  DateTime _month = DateTime(2023, 10);

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final allHistory = ref.watch(attendanceHistoryProvider);
    final lang = ref.watch(localeProvider);

    final history = allHistory
        .where((a) => a.date.year == _month.year && a.date.month == _month.month)
        .toList();

    final present = history.where((a) => a.status == AttendanceStatus.onTime).length;
    final late = history.where((a) => a.status == AttendanceStatus.late).length;
    final absent = history.where((a) => a.status == AttendanceStatus.absent).length;

    final groups = <DateTime, List<Attendance>>{};
    for (final a in history) {
      final monday =
          a.date.subtract(Duration(days: a.date.weekday - DateTime.monday));
      groups.putIfAbsent(_day(monday), () => []).add(a);
    }
    final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: Text(ref.tr('attendanceHistory'))),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 24),
          children: [
            _MonthSelector(
              label: AppDateFormatter.monthLabel(_month, lang),
              onPrev: () => _shiftMonth(-1),
              onNext: () => _shiftMonth(1),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _RecapCard(
                    label: ref.tr('present'),
                    value: present,
                    color: AppColors.primary,
                    daysSuffix: ref.tr('days')),
                const SizedBox(width: 12),
                _RecapCard(
                    label: ref.tr('late'),
                    value: late,
                    color: AppColors.lateFg,
                    daysSuffix: ref.tr('days')),
                const SizedBox(width: 12),
                _RecapCard(
                    label: ref.tr('absent'),
                    value: absent,
                    color: AppColors.absentFg,
                    daysSuffix: ref.tr('days')),
              ],
            ),
            const SizedBox(height: 24),

            if (history.isEmpty)
              _EmptyState(
                month: AppDateFormatter.monthLabel(_month, lang),
                title: ref.tr('noAttendanceData'),
                subtitlePrefix: ref.tr('noRecordForMonth'),
              )
            else
              for (final k in keys) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    AppDateFormatter.weekRangeLabel(k, lang),
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

class _RecapCard extends StatelessWidget {
  const _RecapCard({
    required this.label,
    required this.value,
    required this.color,
    required this.daysSuffix,
  });

  final String label;
  final int value;
  final Color color;
  final String daysSuffix;

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
            Text(daysSuffix, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.month,
    required this.title,
    required this.subtitlePrefix,
  });

  final String month;
  final String title;
  final String subtitlePrefix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.event_busy_outlined,
              size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(title,
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text('$subtitlePrefix $month', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _AttendanceRow extends ConsumerWidget {
  const _AttendanceRow({required this.entry});

  final Attendance entry;

  BadgeStatus get _badge => switch (entry.status) {
        AttendanceStatus.onTime => BadgeStatus.onTime,
        AttendanceStatus.late => BadgeStatus.late,
        AttendanceStatus.absent => BadgeStatus.absent,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    final hasTimes = entry.checkInAt != null && entry.checkOutAt != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppDateFormatter.dayMonth(entry.date, lang),
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
