import 'package:dartz/dartz.dart';
import 'package:runway/core/error/failure.dart';
import 'package:runway/core/error/validation_failure.dart';
import 'package:runway/features/profile/repository/update_profile_repository.dart';

class UpdateProfileUseCase {
  final UpdateProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<Either<Failure, void>> execute(String newDisplayName) async {
    final trimmed = newDisplayName.trim();
    if (trimmed.isEmpty) {
      return const Left(DisplayNameFailure('닉네임을 입력해주세요'));
    }
    if (trimmed.length > 50) {
      return const Left(DisplayNameFailure('닉네임은 50자 이하로 입력해주세요'));
    }

    return await repository.updateProfile(trimmed);
  }
}
