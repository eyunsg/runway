import '../repository/update_profile_repository.dart';

class UpdateProfileUseCase {
  final UpdateProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<Map<String, dynamic>> execute(String newDisplayName) async {
    final result = await repository.updateProfile(newDisplayName);
    print("usecase: $result");
    return result;
  }
}
