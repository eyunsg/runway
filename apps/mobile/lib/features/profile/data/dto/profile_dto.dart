import 'package:runway/domain/entity/profile.dart';

class ProfileDto {
  final String email;
  final String displayName;

  const ProfileDto({required this.email, required this.displayName});

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(email: json['email'], displayName: json['displayName']);
  }

  Profile toEntity() {
    return Profile(email: email, displayName: displayName);
  }
}
