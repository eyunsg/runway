import 'package:flutter_test/flutter_test.dart';
import 'package:runway/domain/entities/password_change_input.dart';

void main() {
  group('PasswordChangeInput 엔티티 테스트', () {
    test('모든 입력 형식이 올바르면 정상적으로 객체가 생성되어야 한다', () {
      expect(
        () => PasswordChangeInput(
          currentPassword: Password('current123!'),
          newPassword: Password('newPassword789'),
          newPasswordConfirm: 'newPassword789',
        ),
        returnsNormally,
      );
    });

    test('비밀번호가 6자 미만이면 Password 객체 생성 시 예외가 발생해야 한다', () {
      expect(() => Password('12345'), throwsArgumentError);
    });

    test('새 비밀번호와 확인값이 다르면 ArgumentError가 발생해야 한다', () {
      expect(
        () => PasswordChangeInput(
          currentPassword: Password('old123456'),
          newPassword: Password('new123456'),
          newPasswordConfirm: 'different123',
        ),
        throwsArgumentError,
      );
    });

    test('현재 비밀번호와 새 비밀번호가 같으면 보안 규칙에 따라 예외가 발생해야 한다', () {
      expect(
        () => PasswordChangeInput(
          currentPassword: Password('samePassword123'),
          newPassword: Password('samePassword123'),
          newPasswordConfirm: 'samePassword123',
        ),
        throwsArgumentError,
      );
    });
  });
}
