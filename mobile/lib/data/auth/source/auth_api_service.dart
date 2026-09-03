import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/data/auth/models/user_creation_req.dart';
import 'package:mobile/data/auth/models/user_signin_req.dart';

const storage = FlutterSecureStorage();

abstract class AuthApiService {
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
  Future<Either> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? profilePicturePath,
  }) async {
    try {
      if (profilePicturePath == null) {
        final response = await http.patch(
          Uri.parse('${baseUrl}user/'),
          headers: await _getHeaders(withAuth: true),
          body: json.encode({
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
          }),
        ).timeout(const Duration(seconds: 20));
        if (response.statusCode == 200) {
          return Right(json.decode(response.body));
        }
        return Left(_profileUpdateError(response));
      }

      final request = http.MultipartRequest('PATCH', Uri.parse('${baseUrl}user/'));
      final headers = await _getHeaders(withAuth: true);
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      request.fields.addAll({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      });
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        profilePicturePath,
      ));
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return Right(json.decode(response.body));
      }
      return Left(_profileUpdateError(response));
    } on TimeoutException {
      return const Left('The request timed out. Please check your connection and try again.');
    } on SocketException {
      return const Left('Unable to connect to StockWise. Please check your internet connection.');
    } on http.ClientException {
      return const Left('We could not reach StockWise right now. Please try again shortly.');
    } catch (_) {
      return const Left('Something went wrong while updating your profile. Please try again.');
    }
  }

  String _profileUpdateError(http.Response response) {
      try {
        final error = json.decode(response.body);
        if (error is Map<String, dynamic>) {
          if (error.containsKey('detail')) {
            final detail = error['detail'].toString().toLowerCase();
            if (detail.contains('authentication') || detail.contains('token')) {
              return 'Your session has expired. Please sign in again.';
            }
            return error['detail'].toString();
          }
          if (error.containsKey('email')) {
            return 'This email address is already in use.';
          }
          if (error.containsKey('first_name') || error.containsKey('last_name')) {
            return 'Please check your name and try again.';
          }
          if (response.statusCode >= 500) {
            return 'StockWise is temporarily unavailable. Please try again later.';
          }
        }
      } catch (_) {
        return 'We could not update your profile. Please try again.';
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        return 'Your session has expired. Please sign in again.';
      }
      if (response.statusCode >= 500) {
        return 'StockWise is temporarily unavailable. Please try again later.';
      }
      return 'We could not update your profile. Please try again.';
  }

  @override
  Future<Either> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}users/change-password/'),
        headers: await _getHeaders(withAuth: true),
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return Right('Password updated successfully');
      }
      if (response.statusCode == 400) {
        final error = json.decode(response.body);
        final detail = error['detail']?.toString().toLowerCase() ?? '';
        if (detail.contains('old password')) {
          return const Left('The current password is incorrect.');
        }
        return const Left('Your new password does not meet the requirements.');
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        return const Left('Your session has expired. Please sign in again.');
      }
      return const Left('We could not change your password. Please try again.');
    } on TimeoutException {
      return const Left('The request timed out. Please check your connection and try again.');
    } on SocketException {
      return const Left('Unable to connect to StockWise. Please check your internet connection.');
    } on http.ClientException {
      return const Left('We could not reach StockWise right now. Please try again shortly.');
    } catch (_) {
      return const Left('Something went wrong while changing your password. Please try again.');
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