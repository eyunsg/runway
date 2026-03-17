import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/domain/entities/password_change_input.dart';
import '../repository/password_change_repository.dart';

class PasswordChangeUsecase {
  final PasswordChangeRepository _repository;

  PasswordChangeUsecase({required PasswordChangeRepository repository})
    : _repository = repository;

  Future<UserResponse> execute(PasswordChangeInput input) async {
    return await _repository.changePassword(
      currentPassword: input.currentPassword,
      newPassword: input.newPassword,
    );
  }
}
