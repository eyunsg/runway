import 'package:supabase_flutter/supabase_flutter.dart';

class GetProfileReposity {
  final SupabaseClient _client;

  GetProfileReposity({required SupabaseClient client}) : _client = client;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.functions.invoke(
      'profile',
      method: HttpMethod.get,
    );

    if (response.status != 200) {
      throw Exception('Failed to fetch profile');
    }

    return response.data;
  }
}
