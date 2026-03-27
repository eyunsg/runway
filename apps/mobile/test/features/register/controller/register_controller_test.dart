import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/features/register/controller/register_controller.dart';
import 'package:runway/features/register/usecase/register_usecase.dart';
import 'package:runway/core/state/async_state.dart';
import 'package:runway/core/error/failure.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

void main() {
  late RegisterController controller;
  late MockRegisterUsecase mockUsecase;

  final fakeUser = User(
    id: 'test-id',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  setUp(() {
    mockUsecase = MockRegisterUsecase();
    controller = RegisterController(mockUsecase);
  });

  test('비밀번호 불일치 시 error 상태', () async {
    when(
      () => mockUsecase.execute(
        email: any(named: 'email'),
        password: any(named: 'password'),
        passwordConfirm: any(named: 'passwordConfirm'),
        displayName: any(named: 'displayName'),
      ),
    ).thenThrow(const AuthFailure('비밀번호가 일치하지 않습니다.'));

    await controller.register(
      email: 'test@test.com',
      password: '123456',
      passwordConfirm: '1234567',
      displayName: 'tester',
    );

    expect(controller.state.status, AsyncStatus.error);
    expect(controller.state.error, isA<AuthFailure>());
    expect(controller.state.error?.message, '비밀번호가 일치하지 않습니다.');
  });

  test('회원가입 성공 시 success 상태', () async {
    when(
      () => mockUsecase.execute(
        email: any(named: 'email'),
        password: any(named: 'password'),
        passwordConfirm: any(named: 'passwordConfirm'),
        displayName: any(named: 'displayName'),
      ),
    ).thenAnswer((_) async => fakeUser);

    await controller.register(
      email: 'test@test.com',
      password: '123456',
      passwordConfirm: '123456',
      displayName: 'tester',
    );

    expect(controller.state.status, AsyncStatus.success);

    verify(
      () => mockUsecase.execute(
        email: 'test@test.com',
        password: '123456',
        passwordConfirm: '123456',
        displayName: 'tester',
      ),
    ).called(1);
  });

  test('회원가입 실패 시 error 상태', () async {
    when(
      () => mockUsecase.execute(
        email: any(named: 'email'),
        password: any(named: 'password'),
        passwordConfirm: any(named: 'passwordConfirm'),
        displayName: any(named: 'displayName'),
      ),
    ).thenThrow(ServerFailure('signup failed'));

    await controller.register(
      email: 'test@test.com',
      password: '123456',
      passwordConfirm: '123456',
      displayName: 'tester',
    );

    expect(controller.state.status, AsyncStatus.error);
    expect(controller.state.error, isA<ServerFailure>());
    expect(controller.state.error?.message, 'signup failed');
  });
}
