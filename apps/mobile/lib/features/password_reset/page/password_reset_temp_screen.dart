import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runway/core/providers.dart';
import 'package:runway/features/password_reset/types/password_reset_state.dart';
import '../../../domain/value_objects/password_reset_input.dart';
import '../../../core/state/async_state.dart';

class PasswordResetTempScreen extends ConsumerWidget {
  const PasswordResetTempScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(resetPasswordControllerProvider.notifier);
    final state = ref.watch(resetPasswordControllerProvider);

    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    ref.listen<PasswordResetState>(resetPasswordControllerProvider, (
      previous,
      next,
    ) {
      if (next.status == AsyncStatus.success) {
        context.go('/login');
      } else if (next.status == AsyncStatus.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error ?? '오류가 발생했습니다.')));
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
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
                    : () {
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                          );
                          return;
                        }

                        final input = PasswordResetInput(
                          password: Password(passwordController.text),
                          passwordConfirm: PasswordConfirm(
                            confirmPasswordController.text,
                          ),
                        );

                        controller.resetPassword(input: input);
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
