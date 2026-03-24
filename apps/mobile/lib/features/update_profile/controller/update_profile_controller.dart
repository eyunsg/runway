import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/update_profile_usecase.dart';
import '../../profile/types/profile_state.dart';

class UpdateProfileController extends StateNotifier<ProfileState> {
  final UpdateProfileUseCase useCase;

  UpdateProfileController({required this.useCase})
    : super(const ProfileState());

  Future<void> updateProfile(String newDisplayName) async {
    try {
      state = state.copyWith(isLoading: true, isSuccess: false, error: null);

      final result = await useCase.execute(newDisplayName);

      print(result);

      // state = state.copyWith(
      //   isLoading: false,
      //   isSuccess: true,
      //   email: result['email'] as String?,
      //   displayName: result['displayName'] as String?,
      // );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  void resetStatus() {
    state = state.copyWith(isSuccess: false, error: null);
  }
}
