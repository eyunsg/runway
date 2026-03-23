import 'package:runway/core/error/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

class DeleteProfileRepository {
  final SupabaseClient client;

  DeleteProfileRepository({required this.client});

  Future<Either<Failure, void>> deleteProfile() async {
    try {
      final session = client.auth.currentSession;
      final accessToken = session!.accessToken;

      final response = await client.functions.invoke(
        'profile',
        method: HttpMethod.delete,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.status != 200) {
        return Left(ServerFailure('Delete failed'));
      }

      await client.auth.signOut();

      return Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
