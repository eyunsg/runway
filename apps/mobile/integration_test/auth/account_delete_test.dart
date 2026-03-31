import 'package:flutter_test/flutter_test.dart';
import 'package:runway/features/profile/repository/delete_profile_repository.dart';
import 'package:runway/features/profile/usecase/delete_profile_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/test_setup.dart';
import '../helpers/test_utils.dart';

void main() {
  late SupabaseClient client;

  late DeleteProfileRepository deleteProfileRepository;
  late DeleteProfileUseCase deleteProfileUseCase;

  const password = '123456';

  setUpAll(() async {
    client = await initTestSupabase();

    deleteProfileRepository = DeleteProfileRepository(client: client);
    deleteProfileUseCase = DeleteProfileUseCase(
      repository: deleteProfileRepository,
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
  /// TC10: 계정 삭제 후 로그인 불가
  /// -------------------------------
  test('TC10: 삭제된 계정으로 로그인 시 실패', () async {
    final email = generateEmail();

    // 회원가입 + 로그인
    await signUp(
      client,
      email: email,
      password: password,
      displayName: 'deleteUser',
    );
    await login(client, email: email, password: password);

    // UseCase로 계정 삭제
    final deleteRes = await deleteProfileUseCase.execute();
    deleteRes.fold(
      (failure) => fail('계정 삭제 실패: ${failure.message}'),
      (_) => null,
    );

    // 삭제 후 로그인 시도
    final loginRes = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    expect(loginRes.session, isNull);
    expect(loginRes.user, isNull);
  });

  /// -------------------------------
  /// TC11: 계정 삭제 후 데이터 제거
  /// -------------------------------
  test('TC11: 계정 삭제 후 프로필 데이터 삭제 확인', () async {
    final email = generateEmail();
    final loginRes = await login(client, email: email, password: password);

    // 삭제 전 userId 저장
    final userId = loginRes.user!.id;

    // UseCase로 계정 삭제
    final deleteRes = await deleteProfileUseCase.execute();
    deleteRes.fold(
      (failure) => fail('계정 삭제 실패: ${failure.message}'),
      (_) => null,
    );

    // 삭제 후 관리자 또는 새로운 클라이언트로 프로필 조회
    final adminClient = await initTestSupabase();
    final response = await adminClient
        .from('profiles')
        .select('*')
        .eq('id', userId);

    final profiles = response as List<dynamic>;
    expect(profiles, isEmpty); // 삭제 확인
  });
}
