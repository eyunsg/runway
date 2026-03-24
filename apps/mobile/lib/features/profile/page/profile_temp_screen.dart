import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runway/core/providers.dart';

class ProfileTempScreen extends ConsumerStatefulWidget {
  const ProfileTempScreen({super.key});

  @override
  ConsumerState<ProfileTempScreen> createState() => _ProfileTempScreenState();
}

class _ProfileTempScreenState extends ConsumerState<ProfileTempScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(deleteProfileControllerProvider, (prev, next) {
      if (next.isSuccess) {
        context.go('/login');
      }

      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text(state.error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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

                  Text(state.displayName ?? ''),
                  const SizedBox(height: 5),

                  Text(
                    state.email ?? '',
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
                    onTap: () {},
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
                ],
              ),
            ),
    );
  }
}
