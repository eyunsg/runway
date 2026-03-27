import 'package:dartz/dartz.dart';
import 'package:runway/domain/value_objects/display_name.dart';
import 'package:runway/domain/value_objects/password.dart';
import 'package:runway/domain/value_objects/email.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/register_repository.dart';
import '../../../core/error/failure.dart';

class RegisterUsecase {
  final RegisterRepository _repository;

  RegisterUsecase({required RegisterRepository repository})
    : _repository = repository;

  Future<Either<Failure, User>> execute({
    required String email,
    required String password,
    required String passwordConfirm,
    required String displayName,
  }) async {
    final emailResult = Email.create(email);
    final displayNameResult = DisplayName.create(displayName);
    final passwordResult = Password.create(password);
    final passwordConfirmResult = Password.create(passwordConfirm);

    return emailResult.fold(
      (failure) => Left(failure),
      (validEmail) => displayNameResult.fold(
        (failure) => Left(failure),
        (validDisplayName) => passwordResult.fold(
          (failure) => Left(failure),
          (validPassword) => passwordConfirmResult.fold(
            (failure) => Left(failure),
            (validPasswordConfirm) {
              final matchResult = validPassword.validateMatches(
                validPasswordConfirm,
              );

              return matchResult.fold((failure) => Left(failure), (_) async {
                final result = await _repository.signUp(
                  email: validEmail.value,
                  password: validPassword.value,
                  displayName: validDisplayName.value,
                );

                return result.fold(
                  (failure) => Left(_mapFailure(failure)),
                  (user) => Right(user),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Failure _mapFailure(Failure failure) {
    if (failure is AuthFailure) {
      final message = failure.message.toLowerCase();

      if (message.contains('already registered')) {
        return AuthFailure('이미 가입된 이메일입니다.');
      }

      return AuthFailure('회원가입에 실패했습니다.');
    }

    return failure;
  }
}
