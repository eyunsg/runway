import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/features/register/repository/register_repository.dart';
import 'package:runway/features/register/usecase/register_usecase.dart';
import 'package:runway/features/login/repository/login_repository.dart';
import 'package:runway/features/login/usecase/login_usecase.dart';
import 'package:runway/features/logout/repository/logout_repository.dart';
import 'package:runway/features/logout/usecase/logout_usecase.dart';
import 'package:runway/features/password_change/repository/password_change_repository.dart';
import 'package:runway/features/password_change/usecase/password_change_usecase.dart';
import 'package:runway/features/password_reset/repository/reset_password_repository.dart';
import 'package:runway/features/password_reset/usecase/reset_password_usecase.dart';

import '../helpers/test_setup.dart';

void main() {
  late SupabaseClient client;

  late RegisterRepository registerRepository;
  late RegisterUsecase registerUsecase;

  late LoginRepository loginRepository;
  late LoginUsecase loginUsecase;

  late LogoutRepository logoutRepository;
  late LogoutUsecase logoutUsecase;

  late PasswordChangeRepository passwordChangeRepository;
  late PasswordChangeUsecase passwordChangeUsecase;

  late ResetPasswordRepository resetPasswordRepository;
  late ResetPasswordUsecase resetPasswordUsecase;

  const initialPassword = '123456';

  setUpAll(() async {
    client = await initTestSupabase();

    registerRepository = RegisterRepository(client: client);
    registerUsecase = RegisterUsecase(repository: registerRepository);

    loginRepository = LoginRepository(client: client);
    loginUsecase = LoginUsecase(repository: loginRepository);

    logoutRepository = LogoutRepository(client: client);
    logoutUsecase = LogoutUsecase(repository: logoutRepository);

    passwordChangeRepository = PasswordChangeRepository(client: client);
    passwordChangeUsecase = PasswordChangeUsecase(
      repository: passwordChangeRepository,
    );

    resetPasswordRepository = ResetPasswordRepository(client: client);
    resetPasswordUsecase = ResetPasswordUsecase(
      repository: resetPasswordRepository,
    );
  });

  setUp(() async {
    await client.auth.signOut();
    await client.rpc('reset_test_data');
  });

  String generateEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'test_$timestamp@test.com';
  }

  /// -------------------------------
  /// TC3: 비밀번호 변경 후 재로그인 가능
  /// -------------------------------
  test('TC3: 로그인 상태에서 비밀번호 변경 후 재로그인 가능', () async {
    final email = generateEmail();

    // 회원가입
    final signUpResult = await registerUsecase.execute(
      email: email,
      password: initialPassword,
      passwordConfirm: initialPassword,
      displayName: 'pwChangeUser',
    );
    expect(signUpResult.isRight(), true);

    // 로그인
    final loginResult = await loginUsecase.execute(
      email: email,
      password: initialPassword,
    );
    expect(loginResult.isRight(), true);

    // 비밀번호 변경
    const newPassword = '654321';
    final changeResult = await passwordChangeUsecase.execute(
      currentPassword: initialPassword,
      newPassword: newPassword,
      newPasswordConfirm: newPassword,
    );
    expect(changeResult.isRight(), true);

    // 로그아웃 후 재로그인
    await logoutUsecase.execute();
    final reLoginResult = await loginUsecase.execute(
      email: email,
      password: newPassword,
    );
    expect(reLoginResult.isRight(), true);
  });

  /// -------------------------------
  /// TC4: 비밀번호 변경 실패 (세션 없음)
  /// -------------------------------
  test('TC4: 잘못된 현재 비밀번호 입력 시 변경 실패', () async {
    final email = generateEmail();

    await registerUsecase.execute(
      email: email,
      password: initialPassword,
      passwordConfirm: initialPassword,
      displayName: 'pwFailUser',
    );

    // 로그아웃 상태에서 변경 시도
    await logoutUsecase.execute();
    final changeResult = await passwordChangeUsecase.execute(
      currentPassword: 'wrongPassword',
      newPassword: 'new12345',
      newPasswordConfirm: 'new12345',
    );

    expect(changeResult.isLeft(), true);
  });

  /// -------------------------------
  /// TC5: 비밀번호 재설정 후 로그인 가능
  /// -------------------------------
  test('TC5: 비밀번호 재설정 후 로그인 가능', () async {
    final email = generateEmail();

    // 회원가입
    await registerUsecase.execute(
      email: email,
      password: initialPassword,
      passwordConfirm: initialPassword,
      displayName: 'pwResetUser',
    );

    // 비밀번호 재설정 UseCase
    const resetPassword = 'reset123';
    final resetResult = await resetPasswordUsecase.execute(
      newPassword: resetPassword,
      passwordConfirm: resetPassword,
    );
    expect(resetResult.isRight(), true);

    // 재로그인
    final loginResult = await loginUsecase.execute(
      email: email,
      password: resetPassword,
    );
    expect(loginResult.isRight(), true);
  });
}
