import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).signUp(
          email: _email.text.trim(),
          password: _password.text,
          username: _username.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      context.go('/verify-email');
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Sign up failed';
      context.showSnack(error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create your account', style: AppTextStyles.h1),
                const SizedBox(height: 6),
                Text('Join 100,000+ students across Africa',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: 28),
                AppTextField(
                  controller: _username,
                  label: 'Username',
                  hint: 'e.g. jay_mwita',
                  validator: Validators.username,
                ),
                const SizedBox(height: 16),
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
                  hint: 'At least 8 characters',
                  obscureText: _obscure,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmPassword,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  obscureText: _obscure,
                  validator: (v) => Validators.confirmPassword(v, _password.text),
                ),
                const SizedBox(height: 28),
                AppButton(label: 'Create Account', isLoading: isLoading, onPressed: _submit),
                const SizedBox(height: 16),
                Text(
                  'By signing up you agree to our Terms of Service and Privacy Policy.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
