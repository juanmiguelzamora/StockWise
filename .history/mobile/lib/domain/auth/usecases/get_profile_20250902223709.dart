import '../entity/profile_entity.dart';
import '../repository/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<ProfileEntity> call() {
    return repository.getProfile();
  }
}
