import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutRepository {
  final SupabaseClient _client;

  LogoutRepository({required SupabaseClient client}) : _client = client;

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('로그아웃 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }
}
