import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/features/password_reset/usecase/request_password_reset_usecase.dart';
import 'package:runway/features/password_reset/controller/request_password_reset_controller.dart';
import 'package:runway/features/password_reset/types/request_password_reset_state.dart';
import 'package:runway/core/state/async_state.dart';

// Mock Usecase 정의
class MockRequestPasswordResetUsecase extends Mock
    implements RequestPasswordResetUsecase {}

void main() {
  late RequestPasswordResetController controller;
  late MockRequestPasswordResetUsecase mockUsecase;

  setUp(() {
    mockUsecase = MockRequestPasswordResetUsecase();
    controller = RequestPasswordResetController(mockUsecase);
  });

  test('requestReset sets status to loading then success on success', () async {
    when(
      () => mockUsecase.execute(email: any(named: 'email')),
    ).thenAnswer((_) async {});

    final states = <RequestPasswordResetState>[];
    controller.addListener((state) => states.add(state));

    await controller.requestReset(email: 'test@example.com');

    // 초기 상태 제외
    final changedStates = states.skip(1).toList();

    expect(changedStates.length, 2);
    expect(changedStates[0].status, AsyncStatus.loading);
    expect(changedStates[1].status, AsyncStatus.success);
    expect(changedStates[1].error, isNull);
  });

  test('requestReset sets status to error on failure', () async {
    when(
      () => mockUsecase.execute(email: any(named: 'email')),
    ).thenThrow(Exception('Failed to send email'));

    final states = <RequestPasswordResetState>[];
    controller.addListener((state) => states.add(state));

    await controller.requestReset(email: 'fail@example.com');

    // 초기 상태 제외
    final changedStates = states.skip(1).toList();

    expect(changedStates.length, 2);
    expect(changedStates[0].status, AsyncStatus.loading);
    expect(changedStates[1].status, AsyncStatus.error);
    expect(changedStates[1].error, 'Failed to send email');
  });
}
