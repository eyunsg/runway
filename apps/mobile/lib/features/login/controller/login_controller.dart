import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/login_usecase.dart';
import '../types/login_state.dart';
import '../../../core/state/async_state.dart';

class LoginController extends StateNotifier<LoginState> {
  final LoginUsecase _usecase;

  LoginController(this._usecase) : super(const LoginState());

  Future<void> login({required String email, required String password}) async {
    if (state.status == AsyncStatus.loading) return;

    state = state.copyWith(status: AsyncStatus.loading, error: null);

    final result = await _usecase.execute(email: email, password: password);

    state = result.fold(
      (failure) => state.copyWith(status: AsyncStatus.error, error: failure),
      (_) => state.copyWith(status: AsyncStatus.success),
    );
  }
}
