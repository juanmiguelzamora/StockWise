import 'package:dartz/dartz.dart';
import 'package:mobile/core/usecase/usecase.dart';
import 'package:mobile/domain/auth/repository/auth.dart';
import 'package:mobile/service_locator.dart';

class SendPasswordResetEmailUseCase implements UseCase<Either,String> {
  
  @override
  Future<Either> call({String ? params}) async {
    return sl<AuthRepository>().forgotPassword(params!);
  }
  
}
