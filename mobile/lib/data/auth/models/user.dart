import 'dart:convert';

import 'package:mobile/domain/auth/entity/user.dart';

class UserModel {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;


  UserModel({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
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
    );
  }

}