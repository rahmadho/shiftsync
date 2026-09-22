import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

/// S6 — Login screen (with branded gradient background).
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
    return Scaffold(
      body: Stack(
        children: [
          // Branded gradient background
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
          // Decorative circles
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
                    const SizedBox(height: 24),
                    // Brand mark on gradient
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
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please sign in to view your shifts.',
                      style: AppTextStyles.bodySm
                          .copyWith(color: Colors.white.withValues(alpha: .85)),
                    ),
                    const SizedBox(height: 40),

                    // Form card
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
                          const Text('Email or Employee ID',
                              style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _idCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Enter your email or ID',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
                            validator: Validators.emailOrId,
                          ),
                          const SizedBox(height: 16),
                          const Text('Password',
                              style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
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
                            validator: Validators.password,
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
                              const Text('Remember me',
                                  style: AppTextStyles.bodySm),
                              const Spacer(),
                              TextButton(
                                onPressed: () {},
                                child: const Text('Forgot Password?',
                                    style:
                                        TextStyle(color: AppColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          PrimaryButton(
                            label: 'Log In',
                            loading: _loading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        "Don't have an account? Contact HR",
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
