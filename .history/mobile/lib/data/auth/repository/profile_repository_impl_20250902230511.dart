import '../../../domain/auth/entity/profile_entity.dart';
import '../../../domain/auth/repository/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<ProfileEntity> getProfile() async {
    // Dummy data for now (later: fetch from API/local storage)
    return const ProfileModel(username: "Johndoe", email: "Johndoe@gmail.com");
  }

  @override
  Future<void> logout() async {
    // Implement logout (clear cache, token, etc.)
  }
}
