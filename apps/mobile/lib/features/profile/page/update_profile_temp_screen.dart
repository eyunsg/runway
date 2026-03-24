import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../types/profile_state.dart';
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

  late final ProviderSubscription<ProfileState> _profileSub;
  late final ProviderSubscription<ProfileState> _updateSub;

  @override
  void initState() {
    super.initState();

    _nicknameController = TextEditingController();

    _profileSub = ref.listenManual<ProfileState>(profileControllerProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;

      final name = next.displayName;
      if (name != null && name != _nicknameController.text) {
        _nicknameController.text = name;
      }
    });

    _updateSub = ref.listenManual<ProfileState>(
      updateProfileControllerProvider,
      (previous, next) {
        if (previous?.isSuccess != true && next.isSuccess == true) {
          ref.invalidate(profileControllerProvider);
          if (mounted) context.pop();
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).fetchProfile();
    });
  }

  @override
  void dispose() {
    _profileSub.close();
    _updateSub.close();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final updateState = ref.watch(updateProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 24),

            const Align(alignment: Alignment.centerLeft, child: Text('이메일')),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: profileState.email ?? "email@gmail.com",
              decoration: const InputDecoration(border: OutlineInputBorder()),
              enabled: false,
            ),
            const SizedBox(height: 16),

            const Align(alignment: Alignment.centerLeft, child: Text('닉네임')),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              enabled: !updateState.isLoading && !profileState.isLoading,
            ),
            const SizedBox(height: 24),

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
                        child: CircularProgressIndicator(strokeWidth: 2),
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
