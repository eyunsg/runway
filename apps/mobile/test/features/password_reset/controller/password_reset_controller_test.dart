import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/core/state/async_state.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/password_reset/controller/password_reset_controller.dart';
import 'package:runway/features/password_reset/types/password_reset_state.dart';
import 'package:runway/features/password_reset/usecase/reset_password_usecase.dart';

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

void main() {
  late PasswordResetController controller;
  late MockResetPasswordUsecase mockUsecase;

  setUp(() {
    mockUsecase = MockResetPasswordUsecase();
    controller = PasswordResetController(mockUsecase);
  });

  tearDown(() {
    controller.dispose();
  });

  test('성공 시: loading → success 상태 전이', () async {
    when(
      () => mockUsecase.execute(
        newPassword: any(named: 'newPassword'),
        passwordConfirm: any(named: 'passwordConfirm'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    final states = <PasswordResetState>[];
    final removeListener = controller.addListener(states.add);

    await controller.resetPassword(
      newPassword: 'Password123!',
      passwordConfirm: 'Password123!',
    );

    removeListener();

    expect(states.map((s) => s.status), [
      AsyncStatus.loading,
      AsyncStatus.success,
    ]);

    expect(states.last.error, isNull);
  });

  test('실패 시: loading → error 상태 전이', () async {
    final failure = UnknownFailure('Reset failed');

    when(
      () => mockUsecase.execute(
        newPassword: any(named: 'newPassword'),
        passwordConfirm: any(named: 'passwordConfirm'),
      ),
    ).thenAnswer((_) async => Left(failure));

    final states = <PasswordResetState>[];
    final removeListener = controller.addListener(states.add);

    await controller.resetPassword(
      newPassword: 'Password123!',
      passwordConfirm: 'Password123!',
    );

    removeListener();

    expect(states.map((s) => s.status), [
      AsyncStatus.loading,
      AsyncStatus.error,
    ]);

    expect(states.last.error, failure);
  });

  test('이미 loading 상태이면 usecase를 호출하지 않는다', () async {
    controller.state = controller.state.copyWith(status: AsyncStatus.loading);

    await controller.resetPassword(
      newPassword: 'Password123!',
      passwordConfirm: 'Password123!',
    );

    verifyNever(
      () => mockUsecase.execute(
        newPassword: any(named: 'newPassword'),
        passwordConfirm: any(named: 'passwordConfirm'),
      ),
    );
  });
}
