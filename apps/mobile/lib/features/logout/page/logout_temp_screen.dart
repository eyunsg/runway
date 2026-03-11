import 'package:flutter/material.dart';

class LogoutTempScreen extends StatelessWidget {
  const LogoutTempScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 로그아웃 로직 연결
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
