import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/state/async_state.dart';
import 'package:runway/features/logout/controller/logout_controller.dart';
import 'package:runway/features/logout/usecase/logout_usecase.dart';

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  late LogoutController controller;
  late MockLogoutUsecase mockUsecase;

  setUp(() {
    mockUsecase = MockLogoutUsecase();
    controller = LogoutController(mockUsecase);
  });

  group('LogoutController', () {
    test('initial state should be AsyncStatus.initial', () {
      expect(controller.debugState.status, AsyncStatus.initial);
    });

    group('logout', () {
      test('should transition through loading to success', () async {
        when(
          () => mockUsecase.execute(),
        ).thenAnswer((_) async => const Right(unit));

        final future = controller.logout();
        expect(controller.debugState.status, AsyncStatus.loading);

        await future;

        expect(controller.debugState.status, AsyncStatus.success);
        verify(() => mockUsecase.execute()).called(1);
      });

      test('should set error status with message on failure', () async {
        const errorMessage = '로그아웃 실패';

        when(
          () => mockUsecase.execute(),
        ).thenAnswer((_) async => Left(ServerFailure(errorMessage)));

        await controller.logout();

        expect(controller.debugState.status, AsyncStatus.error);

        final failure = controller.debugState.error;
        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).message, errorMessage);
      });
    });
  });
}
