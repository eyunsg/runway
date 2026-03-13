import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordRepository {
  final SupabaseClient _client;

  ResetPasswordRepository({required SupabaseClient client}) : _client = client;

  Future<User> resetPassword({required String newPassword}) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      final user = response.user;

      if (user == null) {
        throw Exception('비밀번호 변경에 실패했습니다.');
      }

      return user;
    } on AuthApiException catch (e) {
      throw Exception(e.message);
    }
  }
}
