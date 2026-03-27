import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/register_usecase.dart';
import '../types/register_state.dart';
import '../../../core/state/async_state.dart';
import '../../../core/error/failure.dart';

class RegisterController extends StateNotifier<RegisterState> {
  final RegisterUsecase _usecase;

  RegisterController(this._usecase) : super(const RegisterState());

  Future<void> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String displayName,
  }) async {
    state = state.copyWith(status: AsyncStatus.loading);

    try {
      await _usecase.execute(
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        displayName: displayName,
      );

      state = state.copyWith(status: AsyncStatus.success);
    } catch (e) {
      final failure = e is Failure
          ? e
          : UnknownFailure('알 수 없는 오류가 발생했습니다: ${e.toString()}');

      state = state.copyWith(status: AsyncStatus.error, error: failure);
    }
  }
}
