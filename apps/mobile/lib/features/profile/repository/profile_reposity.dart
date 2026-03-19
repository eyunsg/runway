import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient client;

  ProfileRepository({required this.client});

  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    final response = await client.functions.invoke(
      'user/profile',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.status != 200) {
      throw Exception('Failed to fetch profile');
    }

    return response.data;
  }
}
