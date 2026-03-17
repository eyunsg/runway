import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordChangeRepository {
  final SupabaseClient _client;

  PasswordChangeRepository({required SupabaseClient client}) : _client = client;

  Future<UserResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _client.auth.currentUser;

      if (user == null || user.email == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
      }

      final result = await _client.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      if (result.user == null) {
        throw Exception('현재 비밀번호가 틀렸습니다.');
      }

      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
