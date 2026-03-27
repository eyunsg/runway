import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../repository/logout_repository.dart';

class LogoutUsecase {
  final LogoutRepository _repository;

  LogoutUsecase({required LogoutRepository repository})
    : _repository = repository;

  Future<Either<Failure, Unit>> execute() async {
    final result = await _repository.logout();

    return result.fold(
      (failure) => Left(_mapFailure(failure)),
      (_) => const Right(unit),
    );
  }

  Failure _mapFailure(Failure failure) {
    if (failure is ServerFailure) {
      return ServerFailure('로그아웃 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
    return failure;
  }
}
