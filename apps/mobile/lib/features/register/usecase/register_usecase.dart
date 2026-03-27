import 'package:runway/domain/value_objects/display_name.dart';
import 'package:runway/domain/value_objects/password.dart';
import 'package:runway/domain/value_objects/email.dart';
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
    // email validation
    final emailOrFailure = Email.create(email);
    final emailValue = emailOrFailure.fold(
      (failure) => throw failure,
      (email) => email.value,
    );

    // displayName validation
    final displayNameOrFailure = DisplayName.create(displayName);
    final displayNameValue = displayNameOrFailure.fold(
      (failure) => throw failure,
      (dn) => dn.value,
    );

    // password validation
    final passwordOrFailure = Password.create(password);
    final passwordConfirmOrFailure = Password.create(passwordConfirm);

    final passwordValue = passwordOrFailure.fold(
      (failure) => throw failure,
      (p) => p,
    );
    final passwordConfirmValue = passwordConfirmOrFailure.fold(
      (failure) => throw failure,
      (p) => p,
    );

    // 도메인 객체에서 비밀번호 확인 일치 여부와 현재/새 비밀번호 차이 검증
    passwordValue
        .validateMatches(passwordConfirmValue)
        .fold((failure) => throw failure, (_) => null);

    try {
      final user = await _repository.signUp(
        email: emailValue,
        password: passwordValue.value,
        displayName: displayNameValue,
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
