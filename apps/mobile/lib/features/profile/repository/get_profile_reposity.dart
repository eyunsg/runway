import 'package:supabase_flutter/supabase_flutter.dart';

class GetProfileReposity {
  final SupabaseClient client;

  GetProfileReposity({required this.client});

  Future<Map<String, dynamic>> getProfile() async {
    final session = Supabase.instance.client.auth.currentSession;
    final accessToken = session!.accessToken;

    final response = await client.functions.invoke(
      'profile',
      method: HttpMethod.get,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.status != 200) {
      throw Exception('Failed to fetch profile');
    }

    return response.data;
  }
}
