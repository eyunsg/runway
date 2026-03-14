import 'package:flutter_test/flutter_test.dart';
import 'package:runway/domain/entities/password_change_input.dart';

void main() {
  group('PasswordChangeInput 엔티티 테스트', () {
    test('모든 입력값이 유효하면 정상적으로 객체가 생성되어야 한다', () {
      expect(
        () => PasswordChangeInput(
          currentPassword: 'current123!',
          newPassword: 'newPassword789',
          newPasswordConfirm: 'newPassword789',
        ),
        returnsNormally,
      );
    });

    test('새 비밀번호가 6자 미만이면 ArgumentError가 발생해야 한다', () {
      expect(
        () => PasswordChangeInput(
          currentPassword: 'current123!',
          newPassword: '12345',
          newPasswordConfirm: '12345',
        ),
        throwsArgumentError,
      );
    });

    test('새 비밀번호와 확인값이 다르면 ArgumentError가 발생해야 한다', () {
      expect(
        () => PasswordChangeInput(
          currentPassword: 'old123456',
          newPassword: 'new123456',
          newPasswordConfirm: 'different123',
        ),
        throwsArgumentError,
      );
    });

    test('현재 비밀번호와 새 비밀번호가 같으면 ArgumentError가 발생해야 한다', () {
      expect(
        () => PasswordChangeInput(
          currentPassword: 'samePassword123',
          newPassword: 'samePassword123',
          newPasswordConfirm: 'samePassword123',
        ),
        throwsArgumentError,
      );
    });
  });
}
