import 'package:runway/domain/value_objects/password.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/register_repository.dart';
import '../../../core/error/failure.dart';

class RegisterUsecase {
  final RegisterRepository _repository;

  RegisterUsecase({required RegisterRepository repository})
    : _repository = repository;

  Future<User> execute({
    required String email,
    required String password,
    required String passwordConfirm,
    required String displayName,
  }) async {
    final passwordOrFailure = Password.create(password);
    final passwordConfirmOrFailure = Password.create(passwordConfirm);

    passwordOrFailure.fold((failure) => throw failure, (_) {});

    passwordConfirmOrFailure.fold((failure) => throw failure, (_) {});

    if (password != passwordConfirm) {
      throw const AuthFailure('비밀번호가 일치하지 않습니다.');
    }

    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return user;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure('알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
