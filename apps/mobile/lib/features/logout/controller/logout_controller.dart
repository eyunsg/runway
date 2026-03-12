import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/logout_usecase.dart';
import '../types/logout_state.dart';
import '../../../core/state/async_state.dart';

class LogoutController extends StateNotifier<LogoutState> {
  final LogoutUsecase _usecase;

  LogoutController(this._usecase) : super(const LogoutState());

  Future<void> logout() async {
    state = state.copyWith(status: AsyncStatus.loading);

    try {
      await _usecase.execute();

      state = state.copyWith(status: AsyncStatus.success);
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();

      state = state.copyWith(status: AsyncStatus.error, error: errorMessage);
    }
  }
}
