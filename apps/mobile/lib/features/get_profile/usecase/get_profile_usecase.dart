import 'package:runway/features/get_profile/repository/get_profile_reposity.dart';

class GetProfileUseCase {
  final GetProfileReposity repository;

  GetProfileUseCase(this.repository);

  Future<Map<String, dynamic>> execute() async {
    return await repository.getProfile();
  }
}
