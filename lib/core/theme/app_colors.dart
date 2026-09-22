import 'package:flutter/material.dart';

/// Central color palette for ShiftSync — sampled directly from the design PDF.
abstract final class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2A8CED);
  static const Color primaryDark = Color(0xFF1F6FBF);
  static const Color primaryLight = Color(0xFF84BCF4);

  // Surfaces / neutrals (from design)
  static const Color background = Color(0xFFF6F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2EBF6);

  // Text
  static const Color textPrimary = Color(0xFF111318);
  static const Color textMuted = Color(0xFF55575B);

  // Status — attendance
  static const Color onTime = primary; // On-time = BIRU (confirmed)
  static const Color onTimeBg = Color(0xFFEAF3FD);

  static const Color lateBg = Color(0xFFFFEDD4);
  static const Color lateFg = Color(0xFFC1410C);

  static const Color absentBg = Color(0xFFFDF2F2);
  static const Color absentFg = Color(0xFFB81C1C);

  // Status — leave requests
  static const Color approvedBg = Color(0xFFE8F7EE);
  static const Color approvedFg = Color(0xFF1B7F45);
  static const Color pendingBg = lateBg;
  static const Color pendingFg = lateFg;
  static const Color rejectedBg = absentBg;
  static const Color rejectedFg = absentFg;
}
