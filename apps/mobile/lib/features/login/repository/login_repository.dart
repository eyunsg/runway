import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRepository {
  final SupabaseClient _client;

  LoginRepository({required SupabaseClient client}) : _client = client;

  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        // user가 null이면 로그인 실패
        // SDK가 던지는 AuthApiException에 메시지가 있으므로
        // 이메일 인증 미완료 여부는 catch 블록에서 처리
        throw Exception('로그인에 실패했습니다.');
      }

      return user;
    } on AuthApiException catch (e) {
      // 이메일 인증 미완료 메시지 커스터마이징
      if (e.message.toLowerCase().contains('email not confirmed')) {
        throw Exception('이메일 인증을 완료한 후 로그인해주세요.');
      } else {
        throw Exception(e.message);
      }
    }
  }
}
