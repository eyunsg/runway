import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/async_state.dart';
import '../usecase/reset_password_usecase.dart';
import '../types/password_reset_state.dart';
import '../../../domain/value_objects/password_reset_input.dart';

class PasswordResetController extends StateNotifier<PasswordResetState> {
  final ResetPasswordUsecase _usecase;

  PasswordResetController(this._usecase) : super(const AsyncState<void>());

  Future<void> resetPassword({required PasswordResetInput input}) async {
    state = state.copyWith(status: AsyncStatus.loading);

    try {
      await _usecase.execute(input: input);
      state = state.copyWith(status: AsyncStatus.success);
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      state = state.copyWith(status: AsyncStatus.error, error: errorMessage);
    }
  }
}
