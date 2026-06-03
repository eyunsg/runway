import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    state = state.copyWith(
      status: AsyncStatus.loading,
      error: null,
      message: null,
    );

    final result = await _usecase.execute(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirm: newPasswordConfirm,
    );

    state = result.fold(
      (failure) => state.copyWith(
        status: AsyncStatus.error,
        error: failure,
        message: failure.message,
      ),
      (_) => state.copyWith(
        status: AsyncStatus.success,
        message: '비밀번호가 성공적으로 변경되었습니다.',
      ),
    );
  }
}
