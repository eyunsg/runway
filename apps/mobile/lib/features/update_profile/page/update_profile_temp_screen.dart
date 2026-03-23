import 'package:flutter/material.dart';

class UpdateProfileTempScreen extends StatelessWidget {
  const UpdateProfileTempScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 레포지토리/컨트롤러 작업 시 실제 DB로 교체 예정
    // 현재는 Mock 데이터 배정
    const String userEmail = "email@gmail.com";
    const String userNickname = "Name";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 프로필 섹션
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 16),

            /// 이메일 섹션
            const SizedBox(width: double.infinity, child: Text('이메일')),
            TextFormField(
              initialValue: userEmail,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              enabled: false,
            ),
            const SizedBox(height: 16),

            /// 닉네임 섹션
            const SizedBox(width: double.infinity, child: Text('닉네임')),
            TextFormField(
              initialValue: userNickname,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            /// 버튼 섹션
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('비밀번호 변경'),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('회원탈퇴'),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
