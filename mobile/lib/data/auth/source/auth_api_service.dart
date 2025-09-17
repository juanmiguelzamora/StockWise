import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/data/auth/models/user_creation_req.dart';
import 'package:mobile/data/auth/models/user_signin_req.dart';

//const String baseUrl = 'http://192.168.100.16:8000/api/';
//const String baseUrl = 'https://faeec36a062d.ngrok-free.app/api/';
const storage = FlutterSecureStorage();

abstract class AuthApiService {
  Future<Either> signup(UserCreationReq user);
  Future<Either> signin(UserSigninReq user);
  Future<Either> forgotPassword(String email);
  Future<bool> isLoggedIn();
  Future<Either> getUser();
  Future<Either> logout();
  Future<Either> refreshToken();
}

class AuthApiServiceImpl extends AuthApiService {
  final String baseUrl;

  AuthApiServiceImpl(this.baseUrl);
  Future<Map<String, String>> _getHeaders({bool withAuth = false}) async {
    var headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      var token = await storage.read(key: 'access_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  @override
  Future<Either> signup(UserCreationReq user) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}register/'),
        headers: await _getHeaders(),
        body: json.encode({
          'first_name': user.firstName,
          'last_name': user.lastName,
          'email': user.email,
          'password': user.password,
        }),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await storage.write(key: 'access_token', value: data['access']);
        await storage.write(key: 'refresh_token', value: data['refresh']);
        return Right('User created successfully');
      } else {
        final error = json.decode(response.body);
        return Left(error['email']?.first ?? 'Signup failed');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either> signin(UserSigninReq user) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}token/'),
        headers: await _getHeaders(),
        body: json.encode({
          'email': user.email,
          'password': user.password,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await storage.write(key: 'access_token', value: data['access']);
        await storage.write(key: 'refresh_token', value: data['refresh']);
        return Right('Signin successful');
      } else {
        return Left('Invalid email or password');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}password_reset/'),
        headers: await _getHeaders(),
        body: json.encode({'email': email}),
      );
      if (response.statusCode == 200) {
        return Right('Password reset email sent');
      } else {
        final error = json.decode(response.body);
        return Left(error['email']?.first ?? 'Failed to send reset email');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    var token = await storage.read(key: 'access_token');
    return token != null;
  }

  @override
  Future<Either> getUser() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/'),
        headers: await _getHeaders(withAuth: true),
      );
      if (response.statusCode == 200) {
        return Right(json.decode(response.body));
      } else {
        return Left('Failed to fetch user');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    return Right('User logged out successfully');
  }

  @override
  Future<Either> refreshToken() async {
    try {
        final refreshToken = await storage.read(key: 'refresh_token');
        if (refreshToken == null) return Left('No refresh token');
        final response = await http.post(
            Uri.parse('${baseUrl}token/refresh/'),
            headers: await _getHeaders(),
            body: json.encode({'refresh': refreshToken}),
        );
        if (response.statusCode == 200) {
            final data = json.decode(response.body);
            await storage.write(key: 'access_token', value: data['access']);
            return Right('Token refreshed');
        } else {
            return Left('Failed to refresh token');
        }
    } catch (e) {
        return Left(e.toString());
    }
  }
}