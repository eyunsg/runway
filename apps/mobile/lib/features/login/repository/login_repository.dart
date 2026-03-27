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
        return Left(AuthFailure('로그인에 실패했습니다.'));
      }

      return Right(user);
    } on AuthApiException catch (e) {
      if (e.message.toLowerCase().contains('email not confirmed')) {
        return Left(AuthFailure('이메일 인증을 완료한 후 로그인해주세요.'));
      } else {
        return Left(AuthFailure(e.message));
      }
    } catch (e) {
      return Left(ServerFailure('서버 오류가 발생했습니다.'));
    }
  }
}
