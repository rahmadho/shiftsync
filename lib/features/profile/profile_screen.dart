import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';

/// S5 — My Profile (+ Language switcher & Change Password).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final currentLang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.tr('myProfile'))),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 24),
          children: [
            AppCard(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.onTimeBg,
                    child: Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: AppTextStyles.h2),
                  const SizedBox(height: 2),
                  Text('ID: ${user.employeeCode}',
                      style: AppTextStyles.bodySm),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                            label: ref.tr('department'), value: user.department),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoTile(
                            label: ref.tr('shiftLabel'), value: user.shiftLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(ref.tr('accountSettings'),
                style: AppTextStyles.caption.copyWith(letterSpacing: 1)),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _SettingTile(
                    icon: Icons.bar_chart,
                    label: ref.tr('myStatistics'),
                    onTap: () => context.push('/statistics'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  // Language Setting Tile
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: const Icon(Icons.language, size: 20, color: AppColors.textPrimary),
                    title: Text(ref.tr('language'), style: AppTextStyles.label),
                    trailing: SegmentedButton<AppLanguage>(
                      segments: const [
                        ButtonSegment(value: AppLanguage.en, label: Text('EN', style: TextStyle(fontSize: 11))),
                        ButtonSegment(value: AppLanguage.id, label: Text('ID', style: TextStyle(fontSize: 11))),
                      ],
                      selected: {currentLang},
                      onSelectionChanged: (newSelection) {
                        ref.read(localeProvider.notifier).setLanguage(newSelection.first);
                      },
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _SettingTile(
                    icon: Icons.edit_outlined,
                    label: ref.tr('editProfile'),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _SettingTile(
                    icon: Icons.lock_outline,
                    label: ref.tr('changePassword'),
                    onTap: () => context.push('/change-password'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _SettingTile(
                    icon: Icons.notifications_none,
                    label: ref.tr('notifications'),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _SettingTile(
                    icon: Icons.logout,
                    label: ref.tr('logOut'),
                    color: AppColors.absentFg,
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 20),
      title: Text(label,
          style: AppTextStyles.label.copyWith(color: color)),
      trailing: color == null
          ? const Icon(Icons.chevron_right,
              size: 20, color: AppColors.textMuted)
          : null,
      onTap: onTap,
    );
  }
}
