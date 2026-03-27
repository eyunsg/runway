import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/state/async_state.dart';
import 'package:runway/features/password_change/controller/password_change_controller.dart';
import 'package:runway/features/password_change/usecase/password_change_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:runway/core/error/validation_failure.dart';

class MockPasswordChangeUsecase extends Mock implements PasswordChangeUsecase {}

class MockUserResponse extends Mock implements UserResponse {}

void main() {
  late PasswordChangeController controller;
  late MockPasswordChangeUsecase mockUsecase;

  setUp(() {
    mockUsecase = MockPasswordChangeUsecase();
    controller = PasswordChangeController(mockUsecase);
  });

  group('PasswordChangeController 테스트', () {
    test('초기 상태 검증', () {
      expect(controller.debugState.status, AsyncStatus.initial);
    });

    test('모든 검증 통과 후 비밀번호 변경 성공 시 상태 변화', () async {
      when(
        () => mockUsecase.execute(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirm: any(named: 'newPasswordConfirm'),
        ),
      ).thenAnswer((_) async => MockUserResponse());

      await controller.changePassword(
        currentPassword: 'currentPassword123!',
        newPassword: 'newPassword123!',
        newPasswordConfirm: 'newPassword123!',
      );

      expect(controller.debugState.status, AsyncStatus.success);
      verify(
        () => mockUsecase.execute(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirm: any(named: 'newPasswordConfirm'),
        ),
      ).called(1);
    });

    test('새 비밀번호와 확인값이 다를 때 Input 에러 처리 검증', () async {
      await controller.changePassword(
        currentPassword: 'currentPassword123!',
        newPassword: 'newPassword123!',
        newPasswordConfirm: 'differentPassword!',
      );

      expect(controller.debugState.status, AsyncStatus.error);
      final failure = controller.debugState.error;
      expect(failure, isA<PasswordFailure>());
      expect((failure as PasswordFailure).message, '새 비밀번호가 일치하지 않습니다.');

      verifyNever(
        () => mockUsecase.execute(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirm: any(named: 'newPasswordConfirm'),
        ),
      );
    });

    test('현재 비밀번호와 새 비밀번호가 같을 때 에러 처리 검증', () async {
      await controller.changePassword(
        currentPassword: 'samePassword123!',
        newPassword: 'samePassword123!',
        newPasswordConfirm: 'samePassword123!',
      );

      expect(controller.debugState.status, AsyncStatus.error);
      final failure = controller.debugState.error;
      expect(failure, isA<PasswordFailure>());
      expect(
        (failure as PasswordFailure).message,
        '새 비밀번호는 현재 비밀번호와 다르게 설정해야 합니다.',
      );

      verifyNever(
        () => mockUsecase.execute(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirm: any(named: 'newPasswordConfirm'),
        ),
      );
    });

    test('서버(Usecase)에서 에러 발생 시 상태 처리 검증', () async {
      const serverMsg = '현재 비밀번호가 일치하지 않습니다.';
      when(
        () => mockUsecase.execute(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirm: any(named: 'newPasswordConfirm'),
        ),
      ).thenThrow(PasswordFailure(serverMsg));

      await controller.changePassword(
        currentPassword: 'wrongCurrentPassword',
        newPassword: 'newPassword123!',
        newPasswordConfirm: 'newPassword123!',
      );

      expect(controller.debugState.status, AsyncStatus.error);
      final failure = controller.debugState.error;
      expect(failure, isA<PasswordFailure>());
      expect((failure as PasswordFailure).message, serverMsg);
    });

    test('로딩 중에는 추가 요청을 보내지 않아야 한다 (중복 호출 방지)', () async {
      when(
        () => mockUsecase.execute(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirm: any(named: 'newPasswordConfirm'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return MockUserResponse();
      });

      final firstCall = controller.changePassword(
        currentPassword: 'oldPassword123!',
        newPassword: 'newPassword123!',
        newPasswordConfirm: 'newPassword123!',
      );

      await controller.changePassword(
        currentPassword: 'oldPassword123!',
        newPassword: 'newPassword123!',
        newPasswordConfirm: 'newPassword123!',
      );

      await firstCall;

      verify(
        () => mockUsecase.execute(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirm: any(named: 'newPasswordConfirm'),
        ),
      ).called(1);
    });

    test('작업 시작 시 즉시 loading 상태로 변경되고, 중복 호출 방지 검증', () async {
      final completer = Completer<UserResponse>();
      when(
        () => mockUsecase.execute(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirm: any(named: 'newPasswordConfirm'),
        ),
      ).thenAnswer((_) => completer.future);

      final firstCall = controller.changePassword(
        currentPassword: 'oldPassword123!',
        newPassword: 'newPassword123!',
        newPasswordConfirm: 'newPassword123!',
      );

      expect(controller.debugState.status, AsyncStatus.loading);

      await controller.changePassword(
        currentPassword: 'oldPassword123!',
        newPassword: 'newPassword123!',
        newPasswordConfirm: 'newPassword123!',
      );

      completer.complete(MockUserResponse());
      await firstCall;

      verify(
        () => mockUsecase.execute(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirm: any(named: 'newPasswordConfirm'),
        ),
      ).called(1);

      expect(controller.debugState.status, AsyncStatus.success);
    });
  });
}
