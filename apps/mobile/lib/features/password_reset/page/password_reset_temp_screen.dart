import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runway/core/providers.dart';
import 'package:runway/features/password_reset/types/password_reset_state.dart';
import '../../../core/state/async_state.dart';

class PasswordResetTempScreen extends ConsumerStatefulWidget {
  const PasswordResetTempScreen({super.key});

  @override
  ConsumerState<PasswordResetTempScreen> createState() =>
      _PasswordResetTempScreenState();
}

class _PasswordResetTempScreenState
    extends ConsumerState<PasswordResetTempScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    ref.listen<PasswordResetState>(resetPasswordControllerProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;

      if (next.status == AsyncStatus.success) {
        context.go('/login');
      } else if (next.status == AsyncStatus.error && next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!.message)));
      }
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(resetPasswordControllerProvider.notifier);
    final state = ref.watch(resetPasswordControllerProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: '새 비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.status == AsyncStatus.loading
                    ? null
                    : () async {
                        await controller.resetPassword(
                          newPassword: passwordController.text,
                          passwordConfirm: confirmPasswordController.text,
                        );
                      },
                child: state.status == AsyncStatus.loading
                    ? const CircularProgressIndicator()
                    : const Text('재설정하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
