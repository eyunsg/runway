import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/test_setup.dart';
import '../helpers/test_utils.dart';

void main() {
  late SupabaseClient client;
  const password = '123456';

  setUpAll(() async {
    client = await initTestSupabase();
  });

  setUp(() async {
    await client.auth.signOut();
    await client.rpc('reset_test_data');
  });

  String generateEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'test_$timestamp@test.com';
  }

  test('TC9: 삭제된 계정으로 로그인 시 실패', () async {
    final email = generateEmail();

    // 회원가입 + 로그인
    await signUp(
      client,
      email: email,
      password: password,
      displayName: 'deleteUser',
    );
    await login(client, email: email, password: password);

    // 계정 삭제
    await client.auth.admin.deleteUser(client.auth.currentUser!.id);

    // 삭제 후 로그인 시도
    try {
      final loginRes = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      expect(loginRes.user, isNull);
      expect(loginRes.session, isNull);
    } on AuthApiException catch (e) {
      // 400 invalid_credentials 발생하면 정상
      expect(e.statusCode, '400');
      expect(e.code, 'invalid_credentials');
    }
  });
}
