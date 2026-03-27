import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/core/error/failure.dart';

class PasswordChangeRepository {
  final SupabaseClient _client;

  PasswordChangeRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _client.auth.currentUser;

      if (user == null || user.email == null) {
        return Left(AuthFailure('USER_NOT_FOUND'));
      }

      final result = await _client.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      if (result.user == null) {
        return Left(AuthFailure('INVALID_CURRENT_PASSWORD'));
      }

      await _client.auth.updateUser(UserAttributes(password: newPassword));

      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return Left(ServerFailure('SERVER_ERROR'));
    }
  }
}
