import 'package:dartz/dartz.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';

class Password {
  final String value;

  Password._(this.value);

  static Either<Failure, Password> create(String value) {
    if (value.isEmpty) {
      return Left(PasswordFailure('비밀번호를 입력해주세요.'));
    }

    if (value.length < 6) {
      return Left(PasswordFailure('비밀번호는 6자 이상이어야 합니다.'));
    }

    return Right(Password._(value));
  }
}
