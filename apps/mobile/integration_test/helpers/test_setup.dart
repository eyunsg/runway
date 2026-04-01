import 'package:supabase_flutter/supabase_flutter.dart';

Future<SupabaseClient> initTestSupabase() async {
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_KEY');

  if (url.isEmpty || key.isEmpty) {
    throw Exception('Missing Supabase env');
  }

  await Supabase.initialize(url: url, anonKey: key);

  return Supabase.instance.client;
}
