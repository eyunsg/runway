import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/get_profile_usecase.dart';
import '../types/profile_state.dart';

class GetProfileController extends StateNotifier<ProfileState> {
  final GetProfileUseCase useCase;

  GetProfileController({required this.useCase}) : super(const ProfileState()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    final result = await useCase.execute();

    result.fold(
      // 실패
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isSuccess: false,
        );
      },

      // 성공
      (profile) {
        state = state.copyWith(
          isLoading: false,
          email: profile.email,
          displayName: profile.displayName,
          isSuccess: true,
          error: null,
        );
      },
    );
  }
}
