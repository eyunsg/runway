import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/features/password_reset/types/password_reset_state.dart';

import '../../../core/providers.dart';
import '../../../core/state/async_state.dart';

class RequestPasswordResetTempScreen extends ConsumerStatefulWidget {
  const RequestPasswordResetTempScreen({super.key});

  @override
  ConsumerState<RequestPasswordResetTempScreen> createState() =>
      _RequestPasswordResetTempScreenState();
}

class _RequestPasswordResetTempScreenState
    extends ConsumerState<RequestPasswordResetTempScreen> {
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(
      requestPasswordResetControllerProvider.notifier,
    );
    final state = ref.watch(requestPasswordResetControllerProvider);

    ref.listen<RequestPasswordResetState>(
      requestPasswordResetControllerProvider,
      (previous, next) {
        final msg = ref
            .read(requestPasswordResetControllerProvider.notifier)
            .message;
        if (msg != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
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
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('인증 메일 보내기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
