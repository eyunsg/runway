import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';
import '../usecase/password_change_usecase.dart';
import '../types/password_change_state.dart';
import '../../../core/state/async_state.dart';

class PasswordChangeController extends StateNotifier<PasswordChangeState> {
  final PasswordChangeUsecase _usecase;

  PasswordChangeController(this._usecase) : super(const PasswordChangeState());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    if (state.status == AsyncStatus.loading) return;

    state = state.copyWith(status: AsyncStatus.loading, error: null);

    try {
      await _usecase.execute(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm,
      );

      state = state.copyWith(status: AsyncStatus.success);
    } catch (e) {
      final failure = e is Failure ? e : PasswordFailure(e.toString());
      state = state.copyWith(status: AsyncStatus.error, error: failure);
    }
  }
}
