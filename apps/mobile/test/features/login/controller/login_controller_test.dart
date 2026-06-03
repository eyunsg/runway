import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/features/login/controller/login_controller.dart';
import 'package:runway/features/login/usecase/login_usecase.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/state/async_state.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

void main() {
  late LoginController controller;
  late MockLoginUsecase mockUsecase;

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

  group('LoginController', () {
    const testEmail = "test@test.com";
    const testPassword = "123456";

    void _mockLoginSuccess() {
      when(
        () => mockUsecase.execute(
          email: any(named: "email"),
          password: any(named: "password"),
        ),
      ).thenAnswer((_) async => Right(fakeUser));
    }

    void _mockLoginFailure(String message) {
      when(
        () => mockUsecase.execute(
          email: any(named: "email"),
          password: any(named: "password"),
        ),
      ).thenAnswer((_) async => Left(AuthFailure(message)));
    }

    test('로그인 성공 시 success 상태', () async {
      _mockLoginSuccess();

      await controller.login(email: testEmail, password: testPassword);

      expect(controller.state.status, AsyncStatus.success);
      verify(
        () => mockUsecase.execute(email: testEmail, password: testPassword),
      ).called(1);
    });

    test('로그인 실패 시 error 상태', () async {
      const errorMessage = 'login failed';
      _mockLoginFailure(errorMessage);

      await controller.login(email: testEmail, password: testPassword);

      expect(controller.state.status, AsyncStatus.error);
      expect(controller.state.error, isA<AuthFailure>());
      expect(controller.state.error!.message, errorMessage);
    });
  });
}
