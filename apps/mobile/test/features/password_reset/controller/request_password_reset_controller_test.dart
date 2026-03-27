import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:runway/core/state/async_state.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/features/password_reset/controller/password_reset_controller.dart';
import 'package:runway/features/password_reset/types/password_reset_state.dart';
import 'package:runway/features/password_reset/usecase/reset_password_usecase.dart';

class MockRequestPasswordResetUsecase extends Mock
    implements RequestPasswordResetUsecase {}

void main() {
  late RequestPasswordResetController controller;
  late MockRequestPasswordResetUsecase mockUsecase;

  setUp(() {
    mockUsecase = MockRequestPasswordResetUsecase();
    controller = RequestPasswordResetController(mockUsecase);
  });

  tearDown(() {
    controller.dispose();
  });

  test('Usecase가 성공을 반환하면 loading → success 상태 전이', () async {
    when(
      () => mockUsecase.execute(emailInput: any(named: 'emailInput')),
    ).thenAnswer((_) async => const Right(unit));

    final states = <RequestPasswordResetState>[];

    states.add(controller.state);

    final removeListener = controller.addListener(states.add);

    await controller.requestReset(email: 'test@example.com');

    removeListener();

    expect(states.length, 3);

    expect(states[0].status, AsyncStatus.initial);
    expect(states[1].status, AsyncStatus.loading);
    expect(states[2].status, AsyncStatus.success);
    expect(states[2].error, isNull);
  });

  test('Usecase가 실패하면 loading → error 상태 전이', () async {
    final failure = UnknownFailure('Failed to send email');

    when(
      () => mockUsecase.execute(emailInput: any(named: 'emailInput')),
    ).thenAnswer((_) async => Left(failure));

    final states = <RequestPasswordResetState>[];

    states.add(controller.state);

    final removeListener = controller.addListener(states.add);

    await controller.requestReset(email: 'fail@example.com');

    removeListener();

    expect(states.length, 3);

    expect(states[0].status, AsyncStatus.initial);
    expect(states[1].status, AsyncStatus.loading);
    expect(states[2].status, AsyncStatus.error);
    expect(states[2].error, failure);
  });
}
