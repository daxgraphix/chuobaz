import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authProvider.notifier)
        .signIn(email: _email.text.trim(), password: _password.text);
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Sign in failed';
      context.showSnack(error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 20),
                Text('Welcome back', style: AppTextStyles.h1),
                const SizedBox(height: 6),
                Text('Sign in to continue to ChuoBaz',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.lightTextSecondary)),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  hint: 'you@university.ac.tz',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _password,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _obscure,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Password is required' : null,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 8),
                AppButton(label: 'Sign In', isLoading: isLoading, onPressed: _submit),
                const SizedBox(height: 24),
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or continue with', style: AppTextStyles.caption),
                  ),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await ref.read(authProvider.notifier).signInWithGoogle();
                        if (ok && mounted) context.go('/home');
                      },
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 22),
                      label: const Text('Google'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await ref.read(authProvider.notifier).signInWithApple();
                        if (ok && mounted) context.go('/home');
                      },
                      icon: const Icon(Icons.apple_rounded, size: 22),
                      label: const Text('Apple'),
                    ),
                  ),
                ]),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
