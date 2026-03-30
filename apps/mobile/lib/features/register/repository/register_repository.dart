import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/core/error/failure.dart';

class RegisterRepository {
  final SupabaseClient _client;

  RegisterRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'displayName': displayName},
      );

      final user = response.user;
      if (user == null) {
        return Left(AuthFailure('SIGNUP_FAILED'));
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(UnknownFailure('UNKNOWN_ERROR'));
    }
  }
}
