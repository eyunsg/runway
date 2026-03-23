import 'package:dartz/dartz.dart';

import 'package:runway/core/error/failure.dart';
import 'package:runway/features/profile/repository/delete_profile_repository.dart';

class DeleteProfileUseCase {
  final DeleteProfileRepository repository;

  DeleteProfileUseCase({required this.repository});

  Future<Either<Failure, void>> execute() async {
    return await repository.deleteProfile();
  }
}
