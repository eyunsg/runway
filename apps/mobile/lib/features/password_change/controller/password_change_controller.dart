import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/password_change_usecase.dart';
import '../types/password_change_state.dart';
import '../../../domain/value_objects/password_change_input.dart';
import '../../../core/state/async_state.dart';

class PasswordChangeController extends StateNotifier<PasswordChangeState> {
  final PasswordChangeUsecase _usecase;

  PasswordChangeController(this._usecase) : super(const PasswordChangeState());

  /// 비밀번호 변경 로직 실행
  /// 화면으로부터 입력값들 직접 전달받음
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    if (state.status == AsyncStatus.loading) return;
    state = state.copyWith(status: AsyncStatus.loading, error: null);

    try {
      final input = PasswordChangeInput(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm,
      );

      await _usecase.execute(input);

      state = state.copyWith(status: AsyncStatus.success);
    } catch (e) {
      final errorMessage = e is ArgumentError
          ? e.message.toString()
          : e.toString().replaceFirst('Exception: ', '');

      state = state.copyWith(status: AsyncStatus.error, error: errorMessage);
    }
  }
}
