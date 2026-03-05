import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterRepository {
  final SupabaseClient _client;

  RegisterRepository({required SupabaseClient client}) : _client = client;

  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'displayName': displayName},
    );

    final user = response.user;
    if (user == null) {
      throw Exception('회원가입에 실패했습니다. 입력한 정보를 확인해주세요.');
    }

    return user;
  }
}
