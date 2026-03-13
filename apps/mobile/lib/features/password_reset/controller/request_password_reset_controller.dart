import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecase/request_password_reset_usecase.dart';
import '../types/request_password_reset_state.dart';
import '../../../core/state/async_state.dart';

class RequestPasswordResetController
    extends StateNotifier<RequestPasswordResetState> {
  final RequestPasswordResetUsecase _usecase;

  RequestPasswordResetController(this._usecase)
    : super(const RequestPasswordResetState());

  Future<void> requestReset({required String email}) async {
    state = state.copyWith(status: AsyncStatus.loading);

    try {
      await _usecase.execute(email: email);
      state = state.copyWith(status: AsyncStatus.success);
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      state = state.copyWith(status: AsyncStatus.error, error: errorMessage);
    }
  }
}
