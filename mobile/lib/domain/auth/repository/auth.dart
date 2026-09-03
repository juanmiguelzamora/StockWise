import 'package:dartz/dartz.dart';
import 'package:mobile/data/auth/models/user_creation_req.dart';
import 'package:mobile/data/auth/models/user_signin_req.dart';

abstract class AuthRepository {

  Future<Either> signup(UserCreationReq user);
  Future<Either> signin(UserSigninReq user);
  Future<Either> forgotPassword(String email);
  Future<bool> isLoggedIn();
  Future<Either> getUser();
  Future<Either> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? profilePicturePath,
  });
  Future<Either> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<Either> logout();
}