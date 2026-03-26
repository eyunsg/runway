import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/features/password_reset/usecase/reset_password_usecase.dart';
import 'package:runway/features/password_reset/controller/password_reset_controller.dart';
import 'package:runway/features/password_reset/types/password_reset_state.dart';
import 'package:runway/core/state/async_state.dart';
import 'package:runway/domain/value_objects/password_reset_input.dart';

// Mock Usecase
class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

class FakeUser extends Fake implements User {}

void main() {
  late PasswordResetController controller;
  late MockResetPasswordUsecase mockUsecase;

  setUpAll(() {
    registerFallbackValue(
      PasswordResetInput(
        password: Password('123456'),
        passwordConfirm: PasswordConfirm('123456'),
      ),
    );
  });

  setUp(() {
    mockUsecase = MockResetPasswordUsecase();
    controller = PasswordResetController(mockUsecase);
  });

  test('비밀번호 재설정 성공 시 상태가 loading → success로 변경된다', () async {
    when(
      () => mockUsecase.execute(input: any<PasswordResetInput>(named: 'input')),
    ).thenAnswer((_) async => FakeUser());

    final states = <PasswordResetState>[];
    controller.addListener(states.add);

    await controller.resetPassword(
      input: PasswordResetInput(
        password: Password('123456'),
        passwordConfirm: PasswordConfirm('123456'),
      ),
    );

    final changedStates = states.skip(1).toList();

    expect(changedStates.length, 2);
    expect(changedStates[0].status, AsyncStatus.loading);
    expect(changedStates[1].status, AsyncStatus.success);
    expect(changedStates[1].error, isNull);
  });

  test('비밀번호 재설정 실패 시 상태가 loading → error로 변경되고 에러 메시지가 설정된다', () async {
    when(
      () => mockUsecase.execute(
        input: any(that: isA<PasswordResetInput>(), named: 'input'),
      ),
    ).thenThrow(Exception('Reset failed'));

    final states = <PasswordResetState>[];
    controller.addListener(states.add);

    await controller.resetPassword(
      input: PasswordResetInput(
        password: Password('123456'),
        passwordConfirm: PasswordConfirm('123456'),
      ),
    );

    final changedStates = states.skip(1).toList();

    expect(changedStates.length, 2);
    expect(changedStates[0].status, AsyncStatus.loading);
    expect(changedStates[1].status, AsyncStatus.error);
    expect(changedStates[1].error, 'Reset failed');
  });
}
