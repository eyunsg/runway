import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/types/profile_state.dart';
import 'package:runway/core/providers.dart';
import 'package:go_router/go_router.dart';

class UpdateProfileTempScreen extends ConsumerStatefulWidget {
  const UpdateProfileTempScreen({super.key});

  @override
  ConsumerState<UpdateProfileTempScreen> createState() =>
      _UpdateProfileTempScreenState();
}

class _UpdateProfileTempScreenState
    extends ConsumerState<UpdateProfileTempScreen> {
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: "Name");

    // [추가] 화면이 로드되자마자 실행될 로직을 예약합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).fetchProfile();
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 레포지토리/컨트롤러 작업 시 실제 DB로 교체 예정
    // 현재는 Mock 데이터 배정

    // [추가] 조회용 컨트롤러의 상태를 감시합니다 (이메일, 기존 닉네임 표시용)
    final profileState = ref.watch(profileControllerProvider);

    // [추가] 수정용 컨트롤러의 상태를 감시합니다 (저장 중 로딩 표시용)
    final updateState = ref.watch(updateProfileControllerProvider);

    // [유지] 수정 결과 알림 리스너
    ref.listen<ProfileState>(updateProfileControllerProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('프로필 수정 성공!')));
        context.pop();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('에러 발생: ${next.error}')));
      }
    });

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
              initialValue: profileState.email ?? "email@gmail.com",
              decoration: const InputDecoration(border: OutlineInputBorder()),
              enabled: false,
            ),
            const SizedBox(height: 16),

            /// 닉네임 섹션
            const SizedBox(width: double.infinity, child: Text('닉네임')),
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              enabled: !updateState.isLoading && !profileState.isLoading,
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
                onPressed: (updateState.isLoading || profileState.isLoading)
                    ? null
                    : () {
                        // [변경] 버튼 클릭 시 수정용 컨트롤러에 현재 입력된 텍스트를 전달합니다.
                        ref
                            .read(updateProfileControllerProvider.notifier)
                            .updateProfile(_nicknameController.text);
                      },
                child: updateState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
