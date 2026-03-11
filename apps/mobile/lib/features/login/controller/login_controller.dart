import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/login_usecase.dart';
import '../types/login_state.dart';
import '../../../core/state/async_state.dart';

class LoginController extends StateNotifier<LoginState> {
  final LoginUsecase _usecase;

  LoginController(this._usecase) : super(const LoginState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AsyncStatus.loading);

    try {
      await _usecase.execute(email: email, password: password);

      state = state.copyWith(status: AsyncStatus.success);
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();

      state = state.copyWith(status: AsyncStatus.error, error: errorMessage);
    }
  }
}
