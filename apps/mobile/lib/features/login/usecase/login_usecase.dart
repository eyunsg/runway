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
    if (emailResult.isLeft()) {
      return Left(
        emailResult.fold((failure) => failure, (_) => throw Exception()),
      );
    }

    final passwordResult = Password.create(password);
    if (passwordResult.isLeft()) {
      return Left(
        passwordResult.fold((failure) => failure, (_) => throw Exception()),
      );
    }

    final validEmail = emailResult.getOrElse(() => throw Exception());
    final validPassword = passwordResult.getOrElse(() => throw Exception());

    return await _repository.login(
      email: validEmail.value,
      password: validPassword.value,
    );
  }
}
