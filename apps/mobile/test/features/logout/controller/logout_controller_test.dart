import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:runway/core/state/async_state.dart';
import 'package:runway/features/logout/controller/logout_controller.dart';
import 'package:runway/features/logout/usecase/logout_usecase.dart';

// 1. 가짜 유스케이스 클래스 생성
class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  late LogoutController controller;
  late MockLogoutUsecase mockUsecase;

  setUp(() {
    mockUsecase = MockLogoutUsecase();
    // 의존성 주입: 컨트롤러에 가짜 유스케이스를 넣어줍니다.
    controller = LogoutController(mockUsecase);
  });

  group('LogoutController 테스트', () {
    test('초기 상태는 AsyncStatus.initial 이어야 함', () {
      // debugState는 StateNotifier의 현재 상태를 확인할 때 사용합니다.
      expect(controller.debugState.status, AsyncStatus.initial);
    });

    test('로그아웃 성공 시 상태가 loading을 거쳐 success로 변경되어야 함', () async {
      // 준비: 유스케이스가 아무 에러 없이 실행됨을 가정
      when(() => mockUsecase.execute()).thenAnswer((_) async => {});

      // 실행: 컨트롤러의 로그아웃 호출 (비동기 흐름을 위해 await하지 않고 future에 담음)
      final future = controller.logout();

      // 검증: 호출 직후에는 로딩 상태여야 함
      expect(controller.debugState.status, AsyncStatus.loading);

      await future;

      // 검증: 완료 후에는 성공 상태여야 함
      expect(controller.debugState.status, AsyncStatus.success);
      verify(() => mockUsecase.execute()).called(1); // 실제로 1번 호출됐는지 확인
    });

    test('로그아웃 실패 시 상태가 error로 변경되고 메시지를 담아야 함', () async {
      // 준비: 유스케이스에서 에러가 발생하는 경우 가정
      when(() => mockUsecase.execute()).thenThrow(Exception('로그아웃 실패'));

      // 실행
      await controller.logout();

      // 검증: 상태가 error이고 에러 메시지가 포함되어 있는지 확인
      expect(controller.debugState.status, AsyncStatus.error);
      expect(controller.debugState.error, contains('로그아웃 실패'));
    });
  });
}
