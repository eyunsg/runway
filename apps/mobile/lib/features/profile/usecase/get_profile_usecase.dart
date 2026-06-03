import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/domain/entity/profile.dart';
import 'package:runway/features/profile/repository/get_profile_reposity.dart';

class GetProfileUseCase {
  final GetProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, Profile>> execute() async {
    final result = await repository.getProfile();

    return result.map((dto) => dto.toEntity());
  }
}
