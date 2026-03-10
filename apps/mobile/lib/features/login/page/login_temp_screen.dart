import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginTempScreen extends StatelessWidget {
  const LoginTempScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 비밀번호 재설정 라우트 연결
                },
                child: const Text('비밀번호를 잊으셨나요?'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 로그인 로직 연결
                },
                child: const Text('로그인'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/register');
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
