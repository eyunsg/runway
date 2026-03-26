import 'package:dartz/dartz.dart';

class Email {
  final String value;

  Email._(this.value);

  static Either<String, Email> create(String value) {
    if (value.isEmpty) {
      return Left('이메일을 입력해주세요.');
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return Left('유효한 이메일 형식이 아닙니다.');
    }

    return Right(Email._(value));
  }
}
