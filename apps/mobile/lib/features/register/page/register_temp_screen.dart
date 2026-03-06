import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../controller/register_state.dart';

class RegisterTempScreen extends ConsumerWidget {
  RegisterTempScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final displayNameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);

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
            const SizedBox(height: 16),
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
              controller: passwordConfirmController,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: '별명',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            if (state.status == RegisterStatus.loading)
              const CircularProgressIndicator(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(registerControllerProvider.notifier)
                      .register(
                        email: emailController.text,
                        password: passwordController.text,
                        passwordConfirm: passwordConfirmController.text,
                        displayName: displayNameController.text,
                      );
                },
                child: const Text('회원가입'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
