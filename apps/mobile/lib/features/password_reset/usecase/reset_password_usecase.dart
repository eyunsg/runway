import 'package:runway/features/password_reset/repository/reset_password_repository.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/domain/value_objects/email.dart';
import '../../../domain/value_objects/password.dart';
import 'package:dartz/dartz.dart';

class RequestPasswordResetUsecase {
  final RequestPasswordResetRepository _repository;

  RequestPasswordResetUsecase({
    required RequestPasswordResetRepository repository,
  }) : _repository = repository;

  Future<Either<Failure, Unit>> execute({required String emailInput}) async {
    final emailOrFailure = Email.create(emailInput);

    if (emailOrFailure.isLeft()) {
      return emailOrFailure.map((_) => unit);
    }

    final email = emailOrFailure.getOrElse(() => throw Exception());

    return await _repository.requestPasswordReset(email: email.value);
  }
}

class ResetPasswordUsecase {
  final ResetPasswordRepository _repository;

  ResetPasswordUsecase({required ResetPasswordRepository repository})
    : _repository = repository;

  Future<Either<Failure, Unit>> execute({
    required String newPassword,
    required String passwordConfirm,
  }) async {
    final passwordOrFailure = Password.create(newPassword);
    if (passwordOrFailure.isLeft()) {
      return passwordOrFailure.map((_) => unit);
    }

    final confirmOrFailure = Password.create(passwordConfirm);
    if (confirmOrFailure.isLeft()) {
      return confirmOrFailure.map((_) => unit);
    }

    final password = passwordOrFailure.getOrElse(() => throw Exception());
    final confirm = confirmOrFailure.getOrElse(() => throw Exception());

    final matchValidation = password.validateMatches(confirm);
    if (matchValidation.isLeft()) {
      return matchValidation.map((_) => unit);
    }

    return await _repository.resetPassword(newPassword: password.value);
  }
}
