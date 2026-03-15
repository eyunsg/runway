import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordChangeRepository {
  final SupabaseClient _client;

  PasswordChangeRepository({required SupabaseClient client}) : _client = client;

  Future<UserResponse> changePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
