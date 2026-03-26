import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/get_profile_usecase.dart';
import '../types/profile_state.dart';

class GetProfileController extends StateNotifier<ProfileState> {
  final GetProfileUseCase useCase;

  GetProfileController({required this.useCase}) : super(const ProfileState()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await useCase.execute();

      state = state.copyWith(
        isLoading: false,
        email: result['email'] as String?,
        displayName: result['displayName'] as String?,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
