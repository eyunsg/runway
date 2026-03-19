import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileRepository {
  final String baseUrl =
      "https://tdyfozpynwtiqiqfchjn.supabase.co/functions/v1/user";

  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to fetch profile: ${response.statusCode} ${response.body}",
      );
    }

    return jsonDecode(response.body);
  }
}
