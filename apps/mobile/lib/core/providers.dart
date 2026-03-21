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

import 'package:runway/features/get_profile/controller/get_profile_controller.dart';
import 'package:runway/features/get_profile/repository/get_profile_reposity.dart';
import 'package:runway/features/get_profile/usecase/get_profile_usecase.dart';
import 'package:runway/features/get_profile/types/profile_state.dart';

import '../features/password_change/controller/password_change_controller.dart';
import '../features/password_change/types/password_change_state.dart';
import '../features/password_change/usecase/password_change_usecase.dart';
import '../features/password_change/repository/password_change_repository.dart';

import '../features/logout/controller/logout_controller.dart';
import '../features/logout/types/logout_state.dart';
import '../features/logout/usecase/logout_usecase.dart';
import '../features/logout/repository/logout_repository.dart';

import '../features/password_reset/controller/request_password_reset_controller.dart';
import '../features/password_reset/usecase/request_password_reset_usecase.dart';
import '../features/password_reset/repository/request_password_reset_repository.dart.dart';

import '../features/password_reset/controller/password_reset_controller.dart';
import '../features/password_reset/usecase/reset_password_usecase.dart';
import '../features/password_reset/repository/reset_password_repository.dart';
import '../features/password_reset/types/password_reset_state.dart';

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

/// ---------------- GET PROFILE ----------------

final getProfileRepositoryProvider = Provider<GetProfileReposity>((ref) {
  final client = ref.read(supabaseClientProvider);
  return GetProfileReposity(client: client);
});

final getrofileUsecaseProvider = Provider<GetProfileUseCase>((ref) {
  final repository = ref.read(getProfileRepositoryProvider);
  return GetProfileUseCase(repository);
});

final profileControllerProvider =
    StateNotifierProvider<GetProfileController, ProfileState>((ref) {
      final usecase = ref.read(getrofileUsecaseProvider);
      return GetProfileController(useCase: usecase);
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

/// ---------------- LOGOUT ----------------

final logoutRepositoryProvider = Provider<LogoutRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return LogoutRepository(client: client);
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final repository = ref.read(logoutRepositoryProvider);
  return LogoutUsecase(repository: repository);
});

final logoutControllerProvider =
    StateNotifierProvider<LogoutController, LogoutState>((ref) {
      final usecase = ref.read(logoutUsecaseProvider);
      return LogoutController(usecase);
    });

/// ---------------- PASSWORD RESET ----------------

/// Request Password Reset
final requestPasswordResetRepositoryProvider =
    Provider<RequestPasswordResetRepository>((ref) {
      final client = ref.read(supabaseClientProvider);
      return RequestPasswordResetRepository(client: client);
    });

final requestPasswordResetUsecaseProvider =
    Provider<RequestPasswordResetUsecase>((ref) {
      final repository = ref.read(requestPasswordResetRepositoryProvider);
      return RequestPasswordResetUsecase(repository: repository);
    });

final requestPasswordResetControllerProvider =
    StateNotifierProvider<RequestPasswordResetController, PasswordResetState>((
      ref,
    ) {
      final usecase = ref.read(requestPasswordResetUsecaseProvider);
      return RequestPasswordResetController(usecase);
    });

/// Reset Password
final resetPasswordRepositoryProvider = Provider<ResetPasswordRepository>((
  ref,
) {
  final client = ref.read(supabaseClientProvider);
  return ResetPasswordRepository(client: client);
});

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  final repository = ref.read(resetPasswordRepositoryProvider);
  return ResetPasswordUsecase(repository: repository);
});

final resetPasswordControllerProvider =
    StateNotifierProvider<PasswordResetController, PasswordResetState>((ref) {
      final usecase = ref.read(resetPasswordUsecaseProvider);
      return PasswordResetController(usecase);
    });
