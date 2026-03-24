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
    _nicknameController = TextEditingController();

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
    final profileState = ref.watch(profileControllerProvider);
    final updateState = ref.watch(updateProfileControllerProvider);

    ref.listen<ProfileState>(updateProfileControllerProvider, (previous, next) {
      if (next.isSuccess) {
        context.pop();
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(width: double.infinity, child: Text('이메일')),
            TextFormField(
              initialValue: profileState.email ?? "email@gmail.com",
              decoration: const InputDecoration(border: OutlineInputBorder()),
              enabled: false,
            ),
            const SizedBox(height: 16),

            const SizedBox(width: double.infinity, child: Text('닉네임')),
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              enabled: !updateState.isLoading && !profileState.isLoading,
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (updateState.isLoading || profileState.isLoading)
                    ? null
                    : () {
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
