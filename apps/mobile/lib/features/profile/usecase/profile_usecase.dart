import 'package:runway/features/profile/repository/profile_reposity.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Map<String, dynamic>> execute(String accessToken) async {
    return await repository.getProfile(accessToken);
  }
}
