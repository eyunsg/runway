import '../repository/update_profile_repository.dart';

class UpdateProfileUseCase {
  final UpdateProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  /// Repository가 반환한 Map<String, dynamic>을 변환 없이 그대로 Controller에 전달
  Future<Map<String, dynamic>> execute(String newDisplayName) async {
    return await repository.updateProfile(newDisplayName);
  }
}
