import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRepository {
  final SupabaseClient _client;

  LoginRepository({required SupabaseClient client}) : _client = client;

  Future<User> login({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('로그인에 실패했습니다. 이메일 또는 비밀번호를 확인해주세요.');
    }

    return user;
  }
}
