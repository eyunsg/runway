import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/core/error/failure.dart';

class RequestPasswordResetRepository {
  final SupabaseClient _client;

  RequestPasswordResetRepository({required SupabaseClient client})
    : _client = client;

  Future<Either<Failure, Unit>> requestPasswordReset({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'http://localhost:3000/reset-password/new',
      );

      return const Right(unit);
    } on AuthApiException catch (e) {
      if (e.message.toLowerCase().contains('user not found')) {
        return const Left(AuthFailure('가입되지 않은 이메일입니다.'));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

class ResetPasswordRepository {
  final SupabaseClient _client;

  ResetPasswordRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, Unit>> resetPassword({
    required String newPassword,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      final user = response.user;

      if (user == null) {
        return const Left(ServerFailure('비밀번호 변경에 실패했습니다.'));
      }

      return const Right(unit);
    } on AuthApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
