import 'package:flutter_test/flutter_test.dart';
import 'package:runway/domain/entities/login_input.dart';

void main() {
  group('LoginInput ValueObject', () {
    test('정상 입력 생성', () {
      expect(
        () => LoginInput(
          email: Email('test@example.com'),
          password: Password('abc123!@#'),
        ),
        returnsNormally,
      );
    });

    test('이메일 빈값 예외', () {
      expect(() => Email(''), throwsArgumentError);
    });

    test('이메일 형식 예외', () {
      expect(() => Email('invalid-email'), throwsArgumentError);
    });

    test('비밀번호 짧음 예외', () {
      expect(() => Password('123'), throwsArgumentError);
    });
  });
}
