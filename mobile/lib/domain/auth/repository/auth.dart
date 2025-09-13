import 'package:dartz/dartz.dart';
import 'package:mobile/data/auth/models/user_creation_req.dart';
import 'package:mobile/data/auth/models/user_signin_req.dart';

abstract class AuthRepository {

  Future<Either> signup(UserCreationReq user);
  Future<Either> signin(UserSigninReq user);
  Future<Either> forgotPassword(String email);
  Future<bool> isLoggedIn();
  Future<Either> getUser();
  Future<Either> logout();
  // Future<String> sendMessage(String message);
}