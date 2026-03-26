import 'package:dartz/dartz.dart';
import 'package:runway/domain/value_objects/email.dart';
import 'package:runway/domain/value_objects/password.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repository/login_repository.dart';

class LoginUsecase {
  final LoginRepository _repository;

  LoginUsecase({required LoginRepository repository})
    : _repository = repository;

  Future<Either<String, User>> execute({
    required String email,
    required String password,
  }) async {
    final emailResult = Email.create(email);
    final passwordResult = Password.create(password);

    if (emailResult.isLeft()) {
      return Left(emailResult.swap().getOrElse(() => '이메일 오류'));
    }

    if (passwordResult.isLeft()) {
      return Left(passwordResult.swap().getOrElse(() => '비밀번호 오류'));
    }

    final validEmail = emailResult.getOrElse(() => throw Exception());
    final validPassword = passwordResult.getOrElse(() => throw Exception());

    final user = await _repository.login(
      email: validEmail.value,
      password: validPassword.value,
    );

    return Right(user);
  }
}
