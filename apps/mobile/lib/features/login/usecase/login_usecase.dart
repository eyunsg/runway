import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/domain/value_objects/email.dart';
import 'package:runway/domain/value_objects/password.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repository/login_repository.dart';

class LoginUsecase {
  final LoginRepository _repository;

  LoginUsecase({required LoginRepository repository})
    : _repository = repository;

  Future<Either<Failure, User>> execute({
    required String email,
    required String password,
  }) async {
    final emailResult = Email.create(email);
    final passwordResult = Password.create(password);

    return emailResult.fold(
      (failure) => Left(failure),
      (validEmail) => passwordResult.fold((failure) => Left(failure), (
        validPassword,
      ) async {
        final result = await _repository.login(
          email: validEmail.value,
          password: validPassword.value,
        );

        return result.fold(
          (failure) => Left(_mapFailure(failure)),
          (user) => Right(user),
        );
      }),
    );
  }

  Failure _mapFailure(Failure failure) {
    if (failure is AuthFailure) {
      final message = failure.message.toLowerCase();

      if (message.contains('email not confirmed')) {
        return AuthFailure('이메일 인증을 완료한 후 로그인해주세요.');
      }

      if (message.contains('invalid login credentials')) {
        return AuthFailure('이메일 또는 비밀번호가 올바르지 않습니다.');
      }

      return AuthFailure('로그인에 실패했습니다.');
    }

    return failure;
  }
}
