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

import 'package:runway/features/profile/controller/get_profile_controller.dart';
import 'package:runway/features/profile/repository/get_profile_reposity.dart';
import 'package:runway/features/profile/usecase/get_profile_usecase.dart';
import 'package:runway/features/profile/types/profile_state.dart';

import '../features/password_change/controller/password_change_controller.dart';
import '../features/password_change/types/password_change_state.dart';
import '../features/password_change/usecase/password_change_usecase.dart';
import '../features/password_change/repository/password_change_repository.dart';

import '../features/logout/controller/logout_controller.dart';
import '../features/logout/types/logout_state.dart';
import '../features/logout/usecase/logout_usecase.dart';
import '../features/logout/repository/logout_repository.dart';

import '../features/password_reset/controller/password_reset_controller.dart';
import '../features/password_reset/usecase/reset_password_usecase.dart';
import '../features/password_reset/repository/reset_password_repository.dart';
import '../features/password_reset/types/password_reset_state.dart';

import 'package:runway/features/profile/controller/delete_profile_controller.dart';
import 'package:runway/features/profile/repository/delete_profile_repository.dart';
import 'package:runway/features/profile/types/delete_profile_state.dart';
import 'package:runway/features/profile/usecase/delete_profile_usecase.dart';

import '../features/profile/controller/update_profile_controller.dart';
import '../features/profile/usecase/update_profile_usecase.dart';
import '../features/profile/repository/update_profile_repository.dart';

import 'package:runway/features/portfolio/controller/create_portfolio_controller.dart';
import 'package:runway/features/portfolio/repository/create_portfolio_repository.dart';
import 'package:runway/features/portfolio/types/create_portfolio_state.dart';
import 'package:runway/features/portfolio/usecase/create_portfolio_usecase.dart';

import '../features/simulation/controller/simulation_controller.dart';
import '../features/simulation/usecase/simulation_usecase.dart';
import '../features/simulation/repository/simulation_repository.dart';
import '../features/simulation/types/simulation_state.dart';

import 'package:runway/features/portfolio/repository/get_portfolio_repository.dart';
import 'package:runway/features/portfolio/controller/get_portfolio_controller.dart';
import 'package:runway/features/portfolio/types/get_portfolio_state.dart';
import 'package:runway/features/portfolio/usecase/get_portfolio_usecase.dart';
import 'package:runway/features/portfolio/controller/update_portfolio_controller.dart';
import 'package:runway/features/portfolio/repository/update_portfolio_repository.dart';
import 'package:runway/features/portfolio/usecase/update_portfolio_usecase.dart';

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

final getProfileRepositoryProvider = Provider<GetProfileRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return GetProfileRepository(client: client);
});

final getProfileUsecaseProvider = Provider<GetProfileUseCase>((ref) {
  final repository = ref.read(getProfileRepositoryProvider);
  return GetProfileUseCase(repository);
});

final profileControllerProvider =
    StateNotifierProvider<GetProfileController, ProfileState>((ref) {
      final usecase = ref.read(getProfileUsecaseProvider);
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
    StateNotifierProvider<
      RequestPasswordResetController,
      RequestPasswordResetState
    >((ref) {
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

/// ---------------- DELETE PROFILE ----------------

final deleteProfileRepositoryProvider = Provider<DeleteProfileRepository>((
  ref,
) {
  final client = ref.read(supabaseClientProvider);
  return DeleteProfileRepository(client: client);
});

final deleteProfileUsecaseProvider = Provider<DeleteProfileUseCase>((ref) {
  final repository = ref.read(deleteProfileRepositoryProvider);
  return DeleteProfileUseCase(repository: repository);
});

final deleteProfileControllerProvider =
    StateNotifierProvider<DeleteProfileController, DeleteProfileState>((ref) {
      final usecase = ref.read(deleteProfileUsecaseProvider);
      return DeleteProfileController(deleteProfileUseCase: usecase);
    });

/// ---------------- UPDATE PROFILE ----------------

final updateProfileRepositoryProvider = Provider<UpdateProfileRepository>((
  ref,
) {
  final client = ref.read(supabaseClientProvider);
  return UpdateProfileRepository(client: client);
});

final updateProfileUsecaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.read(updateProfileRepositoryProvider);
  return UpdateProfileUseCase(repository: repository);
});

final updateProfileControllerProvider =
    StateNotifierProvider<UpdateProfileController, ProfileState>((ref) {
      final usecase = ref.read(updateProfileUsecaseProvider);
      return UpdateProfileController(useCase: usecase);
    });

/// ---------------- CREATE PORTFOLIO ----------------

final createPortfolioRepositoryProvider = Provider<CreatePortfolioRepository>((
  ref,
) {
  final client = ref.read(supabaseClientProvider);
  return CreatePortfolioRepository(client: client);
});

final createPortfolioUsecaseProvider = Provider<CreatePortfolioUseCase>((ref) {
  final repository = ref.read(createPortfolioRepositoryProvider);
  return CreatePortfolioUseCase(repository);
});

final createPortfolioControllerProvider =
    StateNotifierProvider<CreatePortfolioController, PortfolioState>((ref) {
      final usecase = ref.read(createPortfolioUsecaseProvider);
      return CreatePortfolioController(useCase: usecase);
    });

/// ---------------- SIMULATION ----------------

final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SimulationRepositoryImpl(client: client);
});

final simulationUseCaseProvider = Provider<SimulationUseCase>((ref) {
  final repository = ref.read(simulationRepositoryProvider);
  return SimulationUseCase(repository);
});

final simulationControllerProvider =
    StateNotifierProvider<SimulationController, SimulationState>((ref) {
      final useCase = ref.read(simulationUseCaseProvider);
      return SimulationController(useCase: useCase);
    });

/// ---------------- GET PORTFOLIO ----------------

final getPortfolioRepositoryProvider = Provider<GetPortfolioRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return GetPortfolioRepository(client: client);
});

final getPortfolioUsecaseProvider = Provider<GetPortfolioUseCase>((ref) {
  final repository = ref.read(getPortfolioRepositoryProvider);
  return GetPortfolioUseCase(repository);
});

final getPortfolioControllerProvider =
    StateNotifierProvider<GetPortfolioController, GetPortfolioState>((ref) {
      final usecase = ref.read(getPortfolioUsecaseProvider);
      return GetPortfolioController(useCase: usecase);
    });

/// ---------------- UPDATE PORTFOLIO ----------------

final updatePortfolioRepositoryProvider = Provider<UpdatePortfolioRepository>((
  ref,
) {
  final client = ref.read(supabaseClientProvider);
  return UpdatePortfolioRepository(client: client);
});

final updatePortfolioUsecaseProvider = Provider<UpdatePortfolioUseCase>((ref) {
  final repository = ref.read(updatePortfolioRepositoryProvider);
  return UpdatePortfolioUseCase(repository);
});

final updatePortfolioControllerProvider =
    StateNotifierProvider<UpdatePortfolioController, PortfolioState>((ref) {
      final usecase = ref.read(updatePortfolioUsecaseProvider);
      return UpdatePortfolioController(useCase: usecase);
    });
