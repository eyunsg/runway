import '../repository/logout_repository.dart';

class LogoutUsecase {
  final LogoutRepository _repository;

  LogoutUsecase({required LogoutRepository repository})
    : _repository = repository;

  Future<void> execute() async {
    return await _repository.logout();
  }
}
