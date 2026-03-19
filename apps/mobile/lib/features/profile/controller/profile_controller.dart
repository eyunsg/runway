import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/profile_usecase.dart';
import '../types/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  final GetProfileUseCase useCase;

  ProfileController({required this.useCase}) : super(const ProfileState());

  Future<void> fetchProfile(String accessToken) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await useCase.execute(accessToken);

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
