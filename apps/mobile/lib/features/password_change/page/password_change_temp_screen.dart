import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordChangePage extends StatelessWidget {
  const PasswordChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            TextField(
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

            ElevatedButton(
              onPressed: () {
                // 임시 클릭 로그
                debugPrint('비밀번호 변경 시도');
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
