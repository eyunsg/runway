import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/features/profile/repository/get_profile_reposity.dart';
import 'package:runway/features/profile/usecase/get_profile_usecase.dart';
import 'package:runway/features/profile/repository/update_profile_repository.dart';
import 'package:runway/features/profile/usecase/update_profile_usecase.dart';

import '../helpers/test_setup.dart';
import '../helpers/test_utils.dart';

void main() {
  late SupabaseClient client;

  late GetProfileRepository getProfileRepository;
  late GetProfileUseCase getProfileUseCase;

  late UpdateProfileRepository updateProfileRepository;
  late UpdateProfileUseCase updateProfileUseCase;

  const password = '123456';

  setUpAll(() async {
    client = await initTestSupabase();

    getProfileRepository = GetProfileRepository(client: client);
    getProfileUseCase = GetProfileUseCase(getProfileRepository);

    updateProfileRepository = UpdateProfileRepository(client: client);
    updateProfileUseCase = UpdateProfileUseCase(
      repository: updateProfileRepository,
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
  /// TC6: 로그인 후 프로필 조회
  /// -------------------------------
  test('TC6: 인증된 유저는 자신의 프로필 조회 가능', () async {
    final email = generateEmail();

    await signUp(
      client,
      email: email,
      password: password,
      displayName: 'profileUser',
    );
    await login(client, email: email, password: password);

    final result = await getProfileUseCase.execute();
    expect(result.isRight(), true);
    result.fold(
      (_) => fail('프로필 조회 실패'),
      (profile) => expect(profile.displayName, 'profileUser'),
    );
  });

  /// -------------------------------
  /// TC7: 프로필 수정 후 조회 시 변경값 반영
  /// -------------------------------
  test('TC7: 프로필 수정 후 조회 시 변경값 반영', () async {
    final email = generateEmail();

    await signUp(
      client,
      email: email,
      password: password,
      displayName: 'oldName',
    );
    await login(client, email: email, password: password);

    // UseCase로 수정
    final updateResult = await updateProfileUseCase.execute('newName');
    expect(updateResult.isRight(), true);

    final profileResult = await getProfileUseCase.execute();
    profileResult.fold(
      (_) => fail('프로필 조회 실패'),
      (profile) => expect(profile.displayName, 'newName'),
    );
  });

  /// -------------------------------
  /// TC8: 인증 없이 접근 차단
  /// -------------------------------
  test('TC8: 비로그인 상태에서 프로필 조회 실패', () async {
    await client.auth.signOut();

    final result = await getProfileUseCase.execute();
    expect(result.isLeft(), true);
  });

  /// -------------------------------
  /// TC9: 다른 유저 데이터 접근 차단 (RLS)
  /// -------------------------------
  test('TC9: 다른 유저의 프로필 조회 불가', () async {
    final email1 = generateEmail();
    final email2 = generateEmail();

    // 유저1 가입 + 로그인
    await signUp(
      client,
      email: email1,
      password: password,
      displayName: 'user1',
    );
    await login(client, email: email1, password: password);

    // 유저2 가입 (다른 클라이언트 세션 사용)
    final client2 = await initTestSupabase();
    await signUp(
      client2,
      email: email2,
      password: password,
      displayName: 'user2',
    );

    // 유저1 세션에서 유저2 프로필 조회 시도 (UseCase 없이 직접 호출)
    final response = await client
        .from('profiles')
        .select('*')
        .eq('id', client2.auth.currentUser!.id);

    expect(response, isEmpty);
  });
}
