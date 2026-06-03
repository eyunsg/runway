import 'package:dartz/dartz.dart';
import 'package:runway/core/error/validation_failure.dart';
import '../../core/error/failure.dart';

class DisplayName {
  final String value;

  DisplayName._(this.value);

  static Either<Failure, DisplayName> create(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return Left(DisplayNameFailure('이름을 입력해주세요.'));
    }

    if (trimmed.length > 20) {
      return Left(DisplayNameFailure('이름은 20자 이하로 입력해주세요.'));
    }

    return Right(DisplayName._(trimmed));
  }
}
