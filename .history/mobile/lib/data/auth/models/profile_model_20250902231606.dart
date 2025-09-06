import 'lib/domain/profile/entity/profile_entity.dart
';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.username,
    required super.email,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      username: json['username'],
      email: json['email'],
    );
  }
}
