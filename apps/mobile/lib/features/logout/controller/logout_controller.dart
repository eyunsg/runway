import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/logout_usecase.dart';
import '../types/logout_state.dart';
import '../../../core/state/async_state.dart';

class LogoutController extends StateNotifier<LogoutState> {
  final LogoutUsecase _usecase;

  LogoutController(this._usecase) : super(const LogoutState());

  Future<void> logout() async {
    if (state.status == AsyncStatus.loading) return;

    state = state.copyWith(status: AsyncStatus.loading, error: null);

    final result = await _usecase.execute();

    state = result.fold(
      (failure) => state.copyWith(status: AsyncStatus.error, error: failure),
      (_) => state.copyWith(status: AsyncStatus.success),
    );
  }
}
