import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

/// S6 — Login screen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _remember = true;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).login(_idCtrl.text, _passCtrl.text);
    if (mounted) {
      setState(() => _loading = false);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF1F6FBF)],
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -30,
            child: _circle(140, Colors.white.withValues(alpha: .08)),
          ),
          Positioned(
            top: 80,
            left: -50,
            child: _circle(120, Colors.white.withValues(alpha: .06)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.badge_outlined,
                              color: Colors.white, size: 30),
                        ),
                        // Language switcher button
                        ActionChip(
                          avatar: const Icon(Icons.language, size: 16, color: Colors.white),
                          label: Text(
                            lang == AppLanguage.en ? 'EN' : 'ID',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: .2),
                          side: BorderSide.none,
                          onPressed: () {
                            ref.read(localeProvider.notifier).toggleLanguage();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ref.tr('welcomeBack'),
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ref.tr('signInSubtitle'),
                      style: AppTextStyles.bodySm
                          .copyWith(color: Colors.white.withValues(alpha: .85)),
                    ),
                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusCard),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ref.tr('emailOrId'),
                              style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _idCtrl,
                            decoration: InputDecoration(
                              hintText: ref.tr('emailOrIdHint'),
                              prefixIcon: const Icon(Icons.person_outline, size: 20),
                            ),
                            validator: (v) => Validators.emailOrId(v, lang),
                          ),
                          const SizedBox(height: 16),
                          Text(ref.tr('password'),
                              style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              hintText: ref.tr('passwordHint'),
                              prefixIcon:
                                  const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => Validators.password(v, lang: lang),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: _remember,
                                activeColor: AppColors.primary,
                                onChanged: (v) =>
                                    setState(() => _remember = v ?? false),
                              ),
                              Text(ref.tr('rememberMe'),
                                  style: AppTextStyles.bodySm),
                              const Spacer(),
                              TextButton(
                                onPressed: () {},
                                child: Text(ref.tr('forgotPassword'),
                                    style:
                                        const TextStyle(color: AppColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          PrimaryButton(
                            label: ref.tr('logIn'),
                            loading: _loading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        ref.tr('contactHr'),
                        style: AppTextStyles.bodySm.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
