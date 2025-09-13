import 'package:dartz/dartz.dart';
import 'package:mobile/data/auth/models/user.dart';
import 'package:mobile/data/auth/models/user_creation_req.dart';
import 'package:mobile/data/auth/models/user_signin_req.dart';
import 'package:mobile/data/auth/source/auth_firebase_service.dart';
import 'package:mobile/domain/auth/repository/auth.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthFireseService _service;

  AuthRepositoryImpl(this._service);

  @override
  Future<Either> signup(UserCreationReq user) async {
    return await _service.signup(user);
  }

  @override
  Future<Either> signin(UserSigninReq user) async {
    return await _service.signin(user);
  }
  
  @override
  Future<Either> forgotPassword(String email) async {
     return await _service.forgotPassword(email);
  }
  
  @override
  Future<bool> isLoggedIn() async {
    return await _service.isLoggedIn();
  }
  
  @override
  Future<Either> getUser() async {
    var user = await _service.getUser();
    return user.fold(
      (error) {
        return Left(error);
      },
      (data) {
        return Right(
          UserModel.fromMap(data).toEntity()
        );
      }
    );
  }
  
  @override
  Future<Either> logout() async {
    return await _service.logout();
  }
}
