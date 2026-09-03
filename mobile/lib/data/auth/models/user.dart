import 'dart:convert';
import 'package:mobile/domain/auth/entity/user.dart';

class UserModel {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  UserModel({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
        'email': email,
        'profilePicture': profilePicture,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['id']?.toString() ?? '',  // Django uses 'id'
      email: map['email'] ?? '',
      firstName: map['first_name'] ?? '',  // Django uses underscore
      lastName: map['last_name'] ?? '',
        profilePicture: map['profile_picture'] as String?,
    );
  }
  
  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension UserXModel on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      firstName: firstName,
        lastName: lastName,
        profilePicture: profilePicture,
    );
  }
}