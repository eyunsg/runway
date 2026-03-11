import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/register/controller/register_controller.dart';
import '../features/register/types/register_state.dart';
import '../features/register/usecase/register_usecase.dart';
import '../features/register/repository/register_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return RegisterRepository(client: client);
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final repository = ref.read(registerRepositoryProvider);
  return RegisterUsecase(repository: repository);
});

final registerControllerProvider =
    StateNotifierProvider<RegisterController, RegisterState>((ref) {
      final usecase = ref.read(registerUsecaseProvider);
      return RegisterController(usecase);
    });
