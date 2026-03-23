import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runway/features/profile/types/delete_profile_state.dart';
import 'package:runway/features/profile/usecase/delete_profile_usecase.dart';

class DeleteProfileController extends StateNotifier<DeleteProfileState> {
  final DeleteProfileUseCase deleteProfileUseCase;

  DeleteProfileController({required this.deleteProfileUseCase})
    : super(DeleteProfileState());

  Future<void> deleteProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await deleteProfileUseCase.execute();

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
