import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../repository/logout_repository.dart';

class LogoutUsecase {
  final LogoutRepository _repository;

  LogoutUsecase({required LogoutRepository repository})
    : _repository = repository;

  Future<Either<Failure, Unit>> execute() async {
    return await _repository.logout();
  }
}
