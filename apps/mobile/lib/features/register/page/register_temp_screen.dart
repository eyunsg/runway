import 'package:flutter/material.dart';

class RegisterTempScreen extends StatelessWidget {
  const RegisterTempScreen({super.key});

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
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '별명',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 회원가입 로직 연결
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
