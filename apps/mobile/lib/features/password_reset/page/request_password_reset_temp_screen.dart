import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/features/password_reset/types/request_password_reset_state.dart';

import '../../../core/providers.dart';
import '../../../core/state/async_state.dart';

class RequestPasswordResetTempScreen extends ConsumerWidget {
  const RequestPasswordResetTempScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      requestPasswordResetControllerProvider.notifier,
    );
    final state = ref.watch(requestPasswordResetControllerProvider);

    final emailController = TextEditingController();

    ref.listen<RequestPasswordResetState>(
      requestPasswordResetControllerProvider,
      (previous, next) {
        if (next.status == AsyncStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('인증 메일이 발송되었습니다.')));
        } else if (next.status == AsyncStatus.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.error ?? '오류가 발생했습니다.')));
        }
      },
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.status == AsyncStatus.loading
                    ? null
                    : () {
                        controller.requestReset(email: emailController.text);
                      },
                child: state.status == AsyncStatus.loading
                    ? const CircularProgressIndicator()
                    : const Text('인증 메일 보내기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
