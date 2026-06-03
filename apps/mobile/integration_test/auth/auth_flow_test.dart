import 'package:flutter_test/flutter_test.dart';
import 'package:runway/features/login/repository/login_repository.dart';
import 'package:runway/features/login/usecase/login_usecase.dart';
import 'package:runway/features/logout/repository/logout_repository.dart';
import 'package:runway/features/logout/usecase/logout_usecase.dart';
import 'package:runway/features/register/repository/register_repository.dart';
import 'package:runway/features/register/usecase/register_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/test_setup.dart';

void main() {
  late SupabaseClient client;

  late RegisterRepository registerRepository;
  late RegisterUsecase registerUsecase;

  late LoginRepository loginRepository;
  late LoginUsecase loginUsecase;

  late LogoutRepository logoutRepository;
  late LogoutUsecase logoutUsecase;

  setUpAll(() async {
    client = await initTestSupabase();

    registerRepository = RegisterRepository(client: client);
    registerUsecase = RegisterUsecase(repository: registerRepository);

    loginRepository = LoginRepository(client: client);
    loginUsecase = LoginUsecase(repository: loginRepository);

    logoutRepository = LogoutRepository(client: client);
    logoutUsecase = LogoutUsecase(repository: logoutRepository);
  });

  setUp(() async {
    await client.auth.signOut();
    await client.rpc('reset_test_data');
  });

  String generateEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'test_$timestamp@test.com';
  }

  const password = '123456';

  /// -------------------------------
  /// TC1. 회원가입 → 로그인 → 프로필 생성 확인
  /// -------------------------------
  test('TC1: 회원가입 후 로그인하면 세션과 프로필이 생성된다', () async {
    final email = generateEmail();
    const displayName = 'testUser';

    // 회원가입
    final signUpResult = await registerUsecase.execute(
      email: email,
      password: password,
      passwordConfirm: password,
      displayName: displayName,
    );
    expect(signUpResult.isRight(), true);

    // 로그인
    final loginResult = await loginUsecase.execute(
      email: email,
      password: password,
    );
    expect(loginResult.isRight(), true);

    final user = loginResult.getOrElse(() => throw Exception('Login failed'));

    // 세션 검증
    expect(client.auth.currentSession, isNotNull);

    // 프로필 테이블 검증
    final profile = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    expect(profile, isNotNull);
    expect(profile['display_name'], displayName);
    expect(profile['created_at'], isNotNull);
    expect(profile['updated_at'], isNotNull);
    expect(profile['deleted_at'], isNull);
  });

  /// -------------------------------
  /// TC2. 로그아웃
  /// -------------------------------
  test('TC2: 로그아웃 시 세션이 제거된다', () async {
    final email = generateEmail();

    await registerUsecase.execute(
      email: email,
      password: password,
      passwordConfirm: password,
      displayName: 'logoutUser',
    );

    await loginUsecase.execute(email: email, password: password);

    // 로그아웃
    await logoutUsecase.execute();

    expect(client.auth.currentSession, isNull);
  });
}
