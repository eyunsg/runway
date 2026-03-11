import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/login_repository.dart';

class LoginUsecase {
  final LoginRepository _repository;

  LoginUsecase({required LoginRepository repository})
    : _repository = repository;

  Future<User> execute({
    required String email,
    required String password,
  }) async {
    return await _repository.login(email: email, password: password);
  }
}
