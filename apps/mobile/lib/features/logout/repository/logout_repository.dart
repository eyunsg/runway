import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/core/error/failure.dart';

class LogoutRepository {
  final SupabaseClient _client;

  LogoutRepository({required SupabaseClient client}) : _client = client;

  Future<Either<Failure, Unit>> logout() async {
    try {
      await _client.auth.signOut();
      return const Right(unit);
    } catch (_) {
      return Left(ServerFailure('로그아웃 실패'));
    }
  }
}
