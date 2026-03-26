import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/login_usecase.dart';
import '../types/login_state.dart';
import '../../../core/state/async_state.dart';

class LoginController extends StateNotifier<LoginState> {
  final LoginUsecase _usecase;

  LoginController(this._usecase) : super(const LoginState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AsyncStatus.loading);

    final result = await _usecase.execute(email: email, password: password);

    result.fold(
      (failure) {
        state = state.copyWith(status: AsyncStatus.error, error: failure);
      },
      (user) {
        state = state.copyWith(status: AsyncStatus.success);
      },
    );
  }
}
