import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Placeholder(fallbackHeight: 120, fallbackWidth: 120),
              ),
            ),
            const SizedBox(height: 40),

            const Align(alignment: Alignment.centerLeft, child: Text('이름')),
            const TextField(
              decoration: InputDecoration(
                labelText: 'UserName',
                border: OutlineInputBorder(),
                enabled: false,
              ),
            ),
            const SizedBox(height: 20),

            const Align(alignment: Alignment.centerLeft, child: Text('닉네임')),
            const TextField(
              decoration: InputDecoration(
                labelText: 'UserNickname',
                border: OutlineInputBorder(),
                enabled: false,
              ),
            ),
            const SizedBox(height: 20),

            const Align(alignment: Alignment.centerLeft, child: Text('이메일')),
            const TextField(
              decoration: InputDecoration(
                labelText: 'user1234@gmail.com',
                border: OutlineInputBorder(),
                enabled: false,
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  // 로그아웃 로직
                },
                child: const Text('로그아웃'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
