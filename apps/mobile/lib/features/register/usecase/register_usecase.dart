import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/register_repository.dart';

class RegisterUsecase {
  final RegisterRepository _repository;

  RegisterUsecase({required RegisterRepository repository})
    : _repository = repository;

  Future<User> execute({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
