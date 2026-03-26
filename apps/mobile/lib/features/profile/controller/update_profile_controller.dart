import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/update_profile_usecase.dart';
import '../types/profile_state.dart';

class UpdateProfileController extends StateNotifier<ProfileState> {
  final UpdateProfileUseCase useCase;
  UpdateProfileController({required this.useCase})
    : super(const ProfileState());
  Future<void> updateProfile(String newDisplayName) async {
    state = state.copyWith(isLoading: true, isSuccess: false, error: null);
    final result = await useCase.execute(newDisplayName);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }
}
