import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signUp(
  SupabaseClient client, {
  required String email,
  required String password,
  required String displayName,
}) async {
  final res = await client.auth.signUp(
    email: email,
    password: password,
    data: {'displayName': displayName},
  );

  expect(res.user, isNotNull);
}

Future<AuthResponse> login(
  SupabaseClient client, {
  required String email,
  required String password,
}) async {
  final res = await client.auth.signInWithPassword(
    email: email,
    password: password,
  );

  expect(res.session, isNotNull);
  expect(res.user, isNotNull);

  return res;
}
