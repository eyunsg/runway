import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/domain/value_objects/password.dart';
import '../repository/password_change_repository.dart';

class PasswordChangeUsecase {
  final PasswordChangeRepository _repository;

  PasswordChangeUsecase({required PasswordChangeRepository repository})
    : _repository = repository;

  Future<UserResponse> execute({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final current = Password.create(
      currentPassword,
    ).fold((l) => throw l, (r) => r);

    final newPwd = Password.create(newPassword).fold((l) => throw l, (r) => r);

    final confirm = Password.create(
      newPasswordConfirm,
    ).fold((l) => throw l, (r) => r);

    newPwd.validateNotSameAs(current).fold((l) => throw l, (r) => r);

    newPwd.validateMatches(confirm).fold((l) => throw l, (r) => r);

    return await _repository.changePassword(
      currentPassword: current.value,
      newPassword: newPwd.value,
    );
  }
}
