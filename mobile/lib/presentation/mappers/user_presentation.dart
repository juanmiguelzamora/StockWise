import 'package:mobile/domain/auth/entity/user.dart';

extension UserPresentation on UserEntity {
  String get fullName => '$firstName $lastName';
  String get greeting => 'Hello, $firstName';
}
