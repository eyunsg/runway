import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/features/login/controller/login_controller.dart';
import 'package:runway/features/login/usecase/login_usecase.dart';
import 'package:runway/core/state/async_state.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

void main() {
  late LoginController controller;
  late MockLoginUsecase mockUsecase;

  // 테스트에서 사용할 fake User
  final fakeUser = User(
    id: 'test-id',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  setUp(() {
    mockUsecase = MockLoginUsecase();
    controller = LoginController(mockUsecase);
  });

  test('로그인 성공 시 success 상태', () async {
    when(
      () => mockUsecase.execute(
        email: any(named: "email"),
        password: any(named: "password"),
      ),
    ).thenAnswer((_) async => fakeUser);

    await controller.login(email: "test@test.com", password: "123456");

    expect(controller.state.status, AsyncStatus.success);

    verify(
      () => mockUsecase.execute(email: "test@test.com", password: "123456"),
    ).called(1);
  });

  test('로그인 실패 시 error 상태', () async {
    when(
      () => mockUsecase.execute(
        email: any(named: "email"),
        password: any(named: "password"),
      ),
    ).thenThrow(Exception("login failed"));

    await controller.login(email: "test@test.com", password: "123456");

    expect(controller.state.status, AsyncStatus.error);
  });
}
