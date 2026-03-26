import 'package:flutter_test/flutter_test.dart';

import 'package:runway/domain/value_objects/email.dart';
import 'package:runway/domain/value_objects/password.dart';

void main() {
  group('Email ValueObject', () {
    test('정상 이메일 생성', () {
      final result = Email.create('test@example.com');

      expect(result.isRight(), true);
    });

    test('이메일 빈값 실패', () {
      final result = Email.create('');

      expect(result.isLeft(), true);
    });

    test('이메일 형식 실패', () {
      final result = Email.create('invalid-email');

      expect(result.isLeft(), true);
    });
  });

  group('Password ValueObject', () {
    test('정상 비밀번호 생성', () {
      final result = Password.create('abc123');

      expect(result.isRight(), true);
    });

    test('비밀번호 짧음 실패', () {
      final result = Password.create('123');

      expect(result.isLeft(), true);
    });
  });
}
