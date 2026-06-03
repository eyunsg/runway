import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/register_usecase.dart';
import '../types/register_state.dart';
import '../../../core/state/async_state.dart';

class RegisterController extends StateNotifier<RegisterState> {
  final RegisterUsecase _usecase;

  RegisterController(this._usecase) : super(const RegisterState());

  Future<void> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String displayName,
  }) async {
    if (state.status == AsyncStatus.loading) return;

    state = state.copyWith(status: AsyncStatus.loading, error: null);

    final result = await _usecase.execute(
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      displayName: displayName,
    );

    state = result.fold(
      (failure) => state.copyWith(status: AsyncStatus.error, error: failure),
      (_) => state.copyWith(status: AsyncStatus.success),
    );
  }
}
