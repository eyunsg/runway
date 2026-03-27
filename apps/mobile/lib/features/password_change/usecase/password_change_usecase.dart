import 'package:dartz/dartz.dart';
import 'package:runway/domain/value_objects/password.dart';
import '../../../core/error/failure.dart';
import '../repository/password_change_repository.dart';

class PasswordChangeUsecase {
  final PasswordChangeRepository _repository;

  PasswordChangeUsecase({required PasswordChangeRepository repository})
    : _repository = repository;

  Future<Either<Failure, Unit>> execute({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final currentResult = Password.create(currentPassword);
    if (currentResult.isLeft()) {
      return Left(currentResult.swap().getOrElse(() => throw Exception()));
    }

    final newResult = Password.create(newPassword);
    if (newResult.isLeft()) {
      return Left(newResult.swap().getOrElse(() => throw Exception()));
    }

    final confirmResult = Password.create(newPasswordConfirm);
    if (confirmResult.isLeft()) {
      return Left(confirmResult.swap().getOrElse(() => throw Exception()));
    }

    final current = currentResult.getOrElse(() => throw Exception());
    final newPwd = newResult.getOrElse(() => throw Exception());
    final confirm = confirmResult.getOrElse(() => throw Exception());

    final notSame = newPwd.validateNotSameAs(current);
    if (notSame.isLeft()) {
      return Left(notSame.swap().getOrElse(() => throw Exception()));
    }

    final match = newPwd.validateMatches(confirm);
    if (match.isLeft()) {
      return Left(match.swap().getOrElse(() => throw Exception()));
    }

    final result = await _repository.changePassword(
      currentPassword: current.value,
      newPassword: newPwd.value,
    );

    return result.fold(
      (failure) => Left(_mapFailure(failure)),
      (_) => const Right(unit),
    );
  }

  Failure _mapFailure(Failure failure) {
    if (failure is AuthFailure) {
      final msg = failure.message.toLowerCase();

      if (msg.contains('invalid_current_password')) {
        return AuthFailure('현재 비밀번호가 올바르지 않습니다.');
      }

      if (msg.contains('user_not_found')) {
        return AuthFailure('다시 로그인해주세요.');
      }

      return AuthFailure('비밀번호 변경에 실패했습니다.');
    }

    return failure;
  }
}
