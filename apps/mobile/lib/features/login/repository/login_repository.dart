import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/core/error/failure.dart';

class LoginRepository {
  final SupabaseClient _client;

  LoginRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        return Left(AuthFailure('LOGIN_FAILED'));
      }

      return Right(user);
    } on AuthApiException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return Left(ServerFailure('SERVER_ERROR'));
    }
  }
}
