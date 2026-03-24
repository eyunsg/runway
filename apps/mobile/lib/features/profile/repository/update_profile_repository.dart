import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runway/core/error/failure.dart';
import 'package:dartz/dartz.dart';

class UpdateProfileRepository {
  final SupabaseClient client;

  UpdateProfileRepository({required this.client});

  Future<Either<Failure, void>> updateProfile(String newDisplayName) async {
    final response = await client.functions.invoke(
      'profile',
      body: {'displayName': newDisplayName},
    );

    if (response.status != 204) {
      return Left(ServerFailure('Update failed'));
    }

    return const Right(null);
  }
}
