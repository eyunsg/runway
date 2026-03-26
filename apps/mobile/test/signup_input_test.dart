import 'package:flutter_test/flutter_test.dart';
import 'package:runway/domain/value_objects/signup_input.dart';

void main() {
  group('SignUpInput ValueObject', () {
    test('정상 입력 생성', () {
      expect(
        () => SignUpInput(
          email: Email('test@example.com'),
          password: Password('abc123!@#'),
          username: Username('홍길동'),
        ),
        returnsNormally,
      );
    });

    test('이메일 빈값 예외', () {
      expect(() => Email(''), throwsArgumentError);
    });

    test('비밀번호 짧음 예외', () {
      expect(() => Password('123'), throwsArgumentError);
    });

    test('사용자명 길이 초과 예외', () {
      expect(() => Username('a' * 51), throwsArgumentError);
    });
  });
}
