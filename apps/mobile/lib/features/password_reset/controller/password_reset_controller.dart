import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/async_state.dart';
import '../usecase/reset_password_usecase.dart';
import '../types/password_reset_state.dart';

class RequestPasswordResetController
    extends StateNotifier<RequestPasswordResetState> {
  final RequestPasswordResetUsecase _usecase;

  RequestPasswordResetController(this._usecase)
    : super(const RequestPasswordResetState());

  Future<void> requestReset({required String email}) async {
    if (state.status == AsyncStatus.loading) return;

    state = state.copyWith(status: AsyncStatus.loading, error: null);

    final result = await _usecase.execute(emailInput: email);

    result.fold(
      (failure) {
        state = state.copyWith(status: AsyncStatus.error, error: failure);
      },
      (_) {
        state = state.copyWith(status: AsyncStatus.success, error: null);
      },
    );
  }
}

class PasswordResetController extends StateNotifier<PasswordResetState> {
  final ResetPasswordUsecase _usecase;

  PasswordResetController(this._usecase) : super(const PasswordResetState());

  Future<void> resetPassword({
    required String newPassword,
    required String passwordConfirm,
  }) async {
    if (state.status == AsyncStatus.loading) return;

    state = state.copyWith(status: AsyncStatus.loading, error: null);

    final result = await _usecase.execute(
      newPassword: newPassword,
      passwordConfirm: passwordConfirm,
    );

    result.fold(
      (failure) {
        state = state.copyWith(status: AsyncStatus.error, error: failure);
      },
      (_) {
        state = state.copyWith(status: AsyncStatus.success, error: null);
      },
    );
  }
}
