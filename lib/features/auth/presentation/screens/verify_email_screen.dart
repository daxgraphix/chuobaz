import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 72),
              const SizedBox(height: 20),
              Text('Verify your email', style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                "We've sent a verification link to ${user?.email ?? 'your email'}. "
                "Please verify it to unlock posting, marketplace, and academic features.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Resend Email',
                outlined: true,
                onPressed: () async {
                  await ref.read(authRepositoryProvider).resendVerificationEmail();
                  if (context.mounted) context.showSnack('Verification email sent');
                },
              ),
              const SizedBox(height: 12),
              AppButton(label: 'Continue to App', onPressed: () => context.go('/home')),
            ],
          ),
        ),
      ),
    );
  }
}
