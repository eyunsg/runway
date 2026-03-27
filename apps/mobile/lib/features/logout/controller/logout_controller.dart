import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/logout_usecase.dart';
import '../types/logout_state.dart';
import '../../../core/state/async_state.dart';
import '../../../core/error/failure.dart';

class LogoutController extends StateNotifier<LogoutState> {
  final LogoutUsecase _usecase;

  LogoutController(this._usecase) : super(const LogoutState());

  Future<void> logout() async {
    state = state.copyWith(status: AsyncStatus.loading);

    try {
      await _usecase.execute();

      state = state.copyWith(status: AsyncStatus.success);
    } catch (e) {
      final failure = e is Failure
          ? e
          : UnknownFailure('알 수 없는 오류가 발생했습니다: ${e.toString()}');

      state = state.copyWith(status: AsyncStatus.error, error: failure);
    }
  }
}
