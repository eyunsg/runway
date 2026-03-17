import 'package:supabase_flutter/supabase_flutter.dart';

class RequestPasswordResetRepository {
  final SupabaseClient _client;

  RequestPasswordResetRepository({required SupabaseClient client})
    : _client = client;

  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'http://localhost:3000/reset-password/new',
      );
    } on AuthApiException catch (e) {
      if (e.message.toLowerCase().contains('user not found')) {
        throw Exception('가입되지 않은 이메일입니다.');
      } else {
        throw Exception(e.message);
      }
    }
  }
}
