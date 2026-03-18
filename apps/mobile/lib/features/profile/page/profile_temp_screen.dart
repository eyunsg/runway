import 'package:flutter/material.dart';

class ProfileTempScreen extends StatelessWidget {
  const ProfileTempScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),

                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            const Text('UserName'),
            const SizedBox(height: 5),

            const Text(
              'user1234@gmail.com',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            ListTile(
              title: const Text('앱 정보'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 앱 정보 화면 이동
              },
            ),

            const Divider(),

            ListTile(
              title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              onTap: () {
                // 로그아웃 팝업
              },
            ),
          ],
        ),
      ),
    );
  }
}
