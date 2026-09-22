import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../widgets/primary_button.dart';

/// Change Password screen (from Profile).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCur = true;
  bool _obscureNew = true;
  bool _obscureConf = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.approvedFg,
        content: Text(ref.tr('passwordChangedSuccess')),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.tr('changePassword'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.tr('changePasswordDesc'),
                  style: AppTextStyles.bodySm,
                ),
                const SizedBox(height: 24),

                Text(ref.tr('currentPassword'), style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _currentCtrl,
                  obscureText: _obscureCur,
                  decoration: InputDecoration(
                    hintText: ref.tr('currentPasswordHint'),
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureCur
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureCur = !_obscureCur),
                    ),
                  ),
                  validator: (v) => Validators.password(v, lang: lang),
                ),
                const SizedBox(height: 16),

                Text(ref.tr('newPassword'), style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newCtrl,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    hintText: ref.tr('newPasswordHint'),
                    prefixIcon: const Icon(Icons.lock_reset, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: (v) => Validators.password(v, lang: lang),
                ),
                const SizedBox(height: 16),

                Text(ref.tr('confirmNewPassword'),
                    style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConf,
                  decoration: InputDecoration(
                    hintText: ref.tr('confirmNewPasswordHint'),
                    prefixIcon: const Icon(Icons.check_circle_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConf
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureConf = !_obscureConf),
                    ),
                  ),
                  validator: (v) {
                    final base = Validators.password(v, lang: lang);
                    if (base != null) return base;
                    if (v != _newCtrl.text) {
                      return ref.tr('passwordsDoNotMatch');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: ref.tr('savePassword'),
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
