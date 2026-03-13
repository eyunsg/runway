import 'package:runway/features/password_reset/repository/request_password_reset_repository.dart.dart';

class RequestPasswordResetUsecase {
  final RequestPasswordResetRepository _repository;

  RequestPasswordResetUsecase({
    required RequestPasswordResetRepository repository,
  }) : _repository = repository;

  Future<void> execute({required String email}) async {
    await _repository.requestPasswordReset(email: email);
  }
}
