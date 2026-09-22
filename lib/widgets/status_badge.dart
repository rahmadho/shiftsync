import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Semantic status for badges (attendance + leave).
enum BadgeStatus { onTime, late, absent, approved, pending, rejected }

/// Small colored pill used across History, Requests and Statistics.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.label});

  final BadgeStatus status;
  final String? label;

  ({String text, Color bg, Color fg}) get _style => switch (status) {
        BadgeStatus.onTime =>
          (text: 'On-time', bg: AppColors.onTimeBg, fg: AppColors.onTime),
        BadgeStatus.late =>
          (text: 'Late', bg: AppColors.lateBg, fg: AppColors.lateFg),
        BadgeStatus.absent =>
          (text: 'Absent', bg: AppColors.absentBg, fg: AppColors.absentFg),
        BadgeStatus.approved =>
          (text: 'Approved', bg: AppColors.approvedBg, fg: AppColors.approvedFg),
        BadgeStatus.pending =>
          (text: 'Pending', bg: AppColors.pendingBg, fg: AppColors.pendingFg),
        BadgeStatus.rejected =>
          (text: 'Rejected', bg: AppColors.rejectedBg, fg: AppColors.rejectedFg),
      };

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label ?? s.text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: s.fg,
        ),
      ),
    );
  }
}
