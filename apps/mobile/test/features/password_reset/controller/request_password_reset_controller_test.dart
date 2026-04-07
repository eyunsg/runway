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

  group('RequestPasswordResetController 상태 흐름 테스트', () {
    test('Usecase 성공 → 상태: initial → loading → success', () async {
      when(
        () => mockUsecase.execute(emailInput: any(named: 'emailInput')),
      ).thenAnswer((_) async => const Right(unit));

      final states = <RequestPasswordResetState>[];

      final removeListener = controller.addListener(states.add);

      await controller.requestReset(email: 'success@example.com');

      removeListener();

      expect(states.map((s) => s.status).toList(), [
        AsyncStatus.initial,
        AsyncStatus.loading,
        AsyncStatus.success,
      ]);
    });

    test('Usecase 실패 → 상태: initial → loading → error', () async {
      final failure = UnknownFailure('Failed to send email');

      when(
        () => mockUsecase.execute(emailInput: any(named: 'emailInput')),
      ).thenAnswer((_) async => Left(failure));

      final states = <RequestPasswordResetState>[];

      final removeListener = controller.addListener(states.add);

      await controller.requestReset(email: 'fail@example.com');

      removeListener();

      expect(states.map((s) => s.status).toList(), [
        AsyncStatus.initial,
        AsyncStatus.loading,
        AsyncStatus.error,
      ]);

      expect(states.last.error, failure);
    });
  });
}
