import 'package:flutter/material.dart';

class RequestPasswordResetTempScreen extends StatelessWidget {
  const RequestPasswordResetTempScreen({super.key});

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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 비밀번호 초기화 로직 연결
                },
                child: const Text('인증 메일 보내기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
