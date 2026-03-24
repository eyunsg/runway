import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProfileRepository {
  final SupabaseClient client;

  UpdateProfileRepository({required this.client});

  Future<Map<String, dynamic>> updateProfile(String newDisplayName) async {
    final session = client.auth.currentSession;
    if (session == null) {
      throw Exception('인증 세션이 만료되었습니다.');
    }

    final accessToken = session.accessToken;

    // Edge Function 호출
    final response = await client.functions.invoke(
      'profile',
      method: HttpMethod.patch,
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'displayName': newDisplayName},
    );

    print(response);

    // 응답 상태 확인
    if (response.status != 200) {
      throw Exception('프로필 수정 중 오류가 발생했습니다. (Status: ${response.status})');
    }

    return response.data as Map<String, dynamic>;
  }
}
