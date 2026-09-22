import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';

enum BadgeStatus { onTime, late, absent, approved, pending, rejected }

class StatusBadge extends ConsumerWidget {
  const StatusBadge({super.key, required this.status, this.label});

  final BadgeStatus status;
  final String? label;

  ({String defaultKey, Color bg, Color fg}) get _style => switch (status) {
        BadgeStatus.onTime => (
            defaultKey: 'statusOnTime',
            bg: AppColors.onTimeBg,
            fg: AppColors.onTime
          ),
        BadgeStatus.late => (
            defaultKey: 'statusLate',
            bg: AppColors.lateBg,
            fg: AppColors.lateFg
          ),
        BadgeStatus.absent => (
            defaultKey: 'statusAbsent',
            bg: AppColors.absentBg,
            fg: AppColors.absentFg
          ),
        BadgeStatus.approved => (
            defaultKey: 'statusApproved',
            bg: AppColors.approvedBg,
            fg: AppColors.approvedFg
          ),
        BadgeStatus.pending => (
            defaultKey: 'statusPending',
            bg: AppColors.pendingBg,
            fg: AppColors.pendingFg
          ),
        BadgeStatus.rejected => (
            defaultKey: 'statusRejected',
            bg: AppColors.rejectedBg,
            fg: AppColors.rejectedFg
          ),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = _style;
    final text = label ?? ref.tr(s.defaultKey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: s.fg,
        ),
      ),
    );
  }
}
