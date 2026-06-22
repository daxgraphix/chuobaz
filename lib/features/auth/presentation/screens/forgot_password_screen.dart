import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mark_email_read_outlined, size: 64),
                    const SizedBox(height: 16),
                    Text('Check your inbox', style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a password reset link to ${_email.text.trim()}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Forgot your password?', style: AppTextStyles.h2),
                      const SizedBox(height: 8),
                      Text(
                        "Enter your email and we'll send you a reset link.",
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _email,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Send Reset Link',
                        isLoading: isLoading,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final ok = await ref
                              .read(authProvider.notifier)
                              .sendPasswordReset(_email.text.trim());
                          if (ok) {
                            setState(() => _sent = true);
                          } else if (mounted) {
                            context.showSnack('Could not send reset link', isError: true);
                          }
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
