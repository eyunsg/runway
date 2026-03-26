import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/features/password_reset/repository/reset_password_repository.dart';
import '../../../domain/value_objects/password_reset_input.dart';

class ResetPasswordUsecase {
  final ResetPasswordRepository _repository;

  ResetPasswordUsecase({required ResetPasswordRepository repository})
    : _repository = repository;

  Future<User> execute({required PasswordResetInput input}) async {
    return await _repository.resetPassword(newPassword: input.password.value);
  }
}
