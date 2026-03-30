import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/state/async_state.dart';
import '../../../core/providers.dart';

class PasswordChangePage extends ConsumerStatefulWidget {
  const PasswordChangePage({super.key});

  @override
  ConsumerState<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends ConsumerState<PasswordChangePage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordChangeControllerProvider);

    ref.listen(passwordChangeControllerProvider, (previous, next) {
      if (next.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }

      if (next.status == AsyncStatus.success) {
        context.go('/login');
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            TextField(
              controller: _currentPasswordController,
              enabled: state.status != AsyncStatus.loading,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '현재 비밀번호',
              ),
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _newPasswordController,
              enabled: state.status != AsyncStatus.loading,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '새 비밀번호',
              ),
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _confirmPasswordController,
              enabled: state.status != AsyncStatus.loading,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '새 비밀번호 확인',
              ),
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            const SizedBox(height: 24),

            state.status == AsyncStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      ref
                          .read(passwordChangeControllerProvider.notifier)
                          .changePassword(
                            currentPassword: _currentPasswordController.text
                                .trim(),
                            newPassword: _newPasswordController.text.trim(),
                            newPasswordConfirm: _confirmPasswordController.text
                                .trim(),
                          );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('비밀번호 변경'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
