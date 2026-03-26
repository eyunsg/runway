import '../repository/update_profile_repository.dart';
import 'package:runway/core/error/failure.dart';
import 'package:dartz/dartz.dart';

class UpdateProfileUseCase {
  final UpdateProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<Either<Failure, void>> execute(String newDisplayName) async {
    return await repository.updateProfile(newDisplayName);
  }
}
