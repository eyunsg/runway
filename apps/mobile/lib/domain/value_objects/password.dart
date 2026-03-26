import 'package:dartz/dartz.dart';

class Password {
  final String value;

  Password._(this.value);

  static Either<String, Password> create(String value) {
    if (value.isEmpty) {
      return const Left('비밀번호를 입력해주세요.');
    }

    if (value.length < 6) {
      return const Left('비밀번호는 6자 이상이어야 합니다.');
    }

    return Right(Password._(value));
  }
}
