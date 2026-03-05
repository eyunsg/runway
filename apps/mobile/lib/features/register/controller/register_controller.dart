import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/register_usecase.dart';
import 'register_state.dart';

class RegisterController extends StateNotifier<RegisterState> {
  final RegisterUsecase _usecase;

  RegisterController(this._usecase) : super(const RegisterState());

  Future<void> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String displayName,
  }) async {
    if (password != passwordConfirm) {
      state = state.copyWith(
        status: RegisterStatus.error,
        errorMessage: '비밀번호가 일치하지 않습니다.',
      );
      return;
    }

    state = state.copyWith(status: RegisterStatus.loading);

    try {
      await _usecase.execute(
        email: email,
        password: password,
        displayName: displayName,
      );

      state = state.copyWith(status: RegisterStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: RegisterStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
