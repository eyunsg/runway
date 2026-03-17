import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/register/controller/register_controller.dart';
import '../features/register/types/register_state.dart';
import '../features/register/usecase/register_usecase.dart';
import '../features/register/repository/register_repository.dart';

import '../features/login/controller/login_controller.dart';
import '../features/login/types/login_state.dart';
import '../features/login/usecase/login_usecase.dart';
import '../features/login/repository/login_repository.dart';

import '../features/password_change/controller/password_change_controller.dart';
import '../features/password_change/types/password_change_state.dart';
import '../features/password_change/usecase/password_change_usecase.dart';
import '../features/password_change/repository/password_change_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// ---------------- REGISTER ----------------

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

/// ---------------- LOGIN ----------------

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return LoginRepository(client: client);
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repository = ref.read(loginRepositoryProvider);
  return LoginUsecase(repository: repository);
});

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
      final usecase = ref.read(loginUsecaseProvider);
      return LoginController(usecase);
    });

/// ---------------- PASSWORD CHANGE ----------------

final passwordChangeRepositoryProvider = Provider<PasswordChangeRepository>((
  ref,
) {
  final client = ref.read(supabaseClientProvider);
  return PasswordChangeRepository(client: client);
});

final passwordChangeUsecaseProvider = Provider<PasswordChangeUsecase>((ref) {
  final repository = ref.read(passwordChangeRepositoryProvider);
  return PasswordChangeUsecase(repository: repository);
});

final passwordChangeControllerProvider =
    StateNotifierProvider<PasswordChangeController, PasswordChangeState>((ref) {
      final usecase = ref.read(passwordChangeUsecaseProvider);
      return PasswordChangeController(usecase);
    });
