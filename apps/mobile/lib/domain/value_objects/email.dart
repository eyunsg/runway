import 'package:dartz/dartz.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';

class Email {
  final String value;

  Email._(this.value);

  static Either<Failure, Email> create(String input) {
    final value = input.trim();

    if (value.isEmpty) {
      return Left(EmailFailure('이메일을 입력해주세요.'));
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegex.hasMatch(value)) {
      return Left(EmailFailure('유효한 이메일 형식이 아닙니다.'));
    }

    return Right(Email._(value));
  }
}
