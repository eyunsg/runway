import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runway/core/providers.dart';
import 'package:runway/core/state/async_state.dart';

class ProfileTempScreen extends ConsumerStatefulWidget {
  const ProfileTempScreen({super.key});

  @override
  ConsumerState<ProfileTempScreen> createState() => _ProfileTempScreenState();
}

class _ProfileTempScreenState extends ConsumerState<ProfileTempScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen(logoutControllerProvider, (previous, next) {
      if (!mounted) return;

      if (next.status == AsyncStatus.success) {
        context.go('/login');
      } else if (next.status == AsyncStatus.error && next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!.message)));
      }
    });

    ref.listen(deleteProfileControllerProvider, (previous, next) {
      if (!mounted) return;

      if (next.isSuccess) {
        context.go('/login');
      } else if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.error != null
          ? Center(child: Text(profileState.error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  /// 프로필 영역
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: const [
                        CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 18),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(profileState.displayName ?? ''),
                  const SizedBox(height: 5),

                  Text(
                    profileState.email ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 40),

                  /// 메뉴 영역
                  ListTile(
                    title: const Text('앱 정보'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),

                  const Divider(),

                  ListTile(
                    title: const Text(
                      '로그아웃',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      final controller = ref.read(
                        logoutControllerProvider.notifier,
                      );
                      await controller.logout();
                    },
                  ),

                  const Divider(),

                  ListTile(
                    title: const Text(
                      '회원탈퇴 (임시)',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      ref
                          .read(deleteProfileControllerProvider.notifier)
                          .deleteProfile();
                    },
                  ),

                  const Divider(),

                  ListTile(
                    title: const Text('회원정보 수정 (임시)'),
                    onTap: () {
                      context.push('/profile/update');
                    },
                  ),

                  const Divider(),

                  ListTile(
                    title: const Text('시뮬레이션 (임시)'),
                    onTap: () {
                      context.push('/simulation');
                    },
                  ),

                  const Divider(),

                  ListTile(
                    title: const Text('내 포트폴리오'),
                    onTap: () {
                      context.push('/portfolio/get');
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
