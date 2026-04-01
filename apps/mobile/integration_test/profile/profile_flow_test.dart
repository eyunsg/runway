import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runway/features/profile/repository/get_profile_reposity.dart';
import 'package:runway/features/profile/usecase/get_profile_usecase.dart';

import '../helpers/test_setup.dart';
import '../helpers/test_utils.dart';

void main() {
  late SupabaseClient client;

  late GetProfileRepository getProfileRepository;
  late GetProfileUseCase getProfileUseCase;

  const password = '123456';

  setUpAll(() async {
    client = await initTestSupabase();

    getProfileRepository = GetProfileRepository(client: client);
    getProfileUseCase = GetProfileUseCase(getProfileRepository);
  });

  setUp(() async {
    await client.auth.signOut();
    await client.rpc('reset_test_data');
  });

  String generateEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'test_${timestamp}_$random@test.com';
  }

  /// -------------------------------
  /// TC6: 로그인 후 프로필 조회
  /// -------------------------------
  test('TC6: 인증된 유저는 자신의 프로필 조회 가능', () async {
    final email = generateEmail();

    // 회원가입 + 로그인
    await signUp(
      client,
      email: email,
      password: password,
      displayName: 'profileUser',
    );
    final loginRes = await login(client, email: email, password: password);

    // 로그인 직후 Supabase에서 직접 프로필 조회
    final userId = loginRes.user!.id;

    final response = await client
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      fail('프로필 조회 실패: 데이터 없음');
    } else {
      expect(response['display_name'], 'profileUser');
    }
  });

  /// -------------------------------
  /// TC7: 프로필 수정 후 조회 시 변경값 반영
  /// -------------------------------
  test('TC7: 프로필 수정 후 조회 시 변경값 반영', () async {
    final email = generateEmail();

    // 회원가입 + 로그인
    await signUp(
      client,
      email: email,
      password: password,
      displayName: 'oldName',
    );
    final loginRes = await login(client, email: email, password: password);
    final userId = loginRes.user!.id;

    // Supabase 직접 업데이트
    final updateResponse = await client
        .from('profiles')
        .update({'display_name': 'newName'})
        .eq('id', userId)
        .select();

    expect(updateResponse, isNotEmpty, reason: '프로필 수정 실패');

    // Supabase 직접 조회
    final profile = await client
        .from('profiles')
        .select('display_name')
        .eq('id', userId)
        .maybeSingle();

    expect(profile, isNotNull, reason: '프로필 조회 실패');
    expect(profile!['display_name'], 'newName');
  });

  /// -------------------------------
  /// TC8: 인증 없이 접근 차단
  /// -------------------------------
  test('TC8: 비로그인 상태에서 프로필 조회 실패', () async {
    await client.auth.signOut();

    final result = await getProfileUseCase.execute();
    expect(result.isLeft(), true);
  });
}
