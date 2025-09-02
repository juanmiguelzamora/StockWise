import 'package:dartz/dartz.dart';
import 'package:mobile/domain/auth/repository/auth.dart';
import 'package:mobile/service_locator.dart';

class LogoutUseCase {
  final AuthRepository _repository = sl<AuthRepository>();

  Future<Either> call() async {
    return await _repository.logout();
  }
}
