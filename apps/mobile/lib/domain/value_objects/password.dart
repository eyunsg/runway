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
    if (value.contains(RegExp(r'\s'))) {
      return Left(PasswordFailure('비밀번호에는 공백을 포함할 수 없습니다.'));
    }
    if (value.length < 6) {
      return Left(PasswordFailure('비밀번호는 6자 이상이어야 합니다.'));
    }
    return Right(Password._(value));
  }

  Either<Failure, Password> validateNotSameAs(Password other) {
    if (value == other.value) {
      return Left(PasswordFailure('새 비밀번호는 현재 비밀번호와 달라야 합니다.'));
    }
    return Right(this);
  }

  Either<Failure, Password> validateMatches(Password confirm) {
    if (value != confirm.value) {
      return Left(PasswordFailure('비밀번호 확인이 일치하지 않습니다.'));
    }
    return Right(this);
  }
}
