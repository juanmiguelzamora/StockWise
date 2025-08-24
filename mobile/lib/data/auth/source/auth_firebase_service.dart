import 'package:dartz/dartz.dart';
import 'package:mobile/data/auth/models/user_creation_req.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/data/auth/models/user_signin_req.dart';

abstract class AuthFireseService {
  Future<Either> signup(UserCreationReq user);
  Future<Either> signin(UserSigninReq user);
  Future<Either> forgotPassword(String email);
  Future<bool> isLoggedIn();
  Future<Either> getUser();
}

class AuthFirebaseServiceImpl extends AuthFireseService {
  @override
  Future<Either> signup(UserCreationReq user) async {
    try {
      var returnedData = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: user.email!,
            password: user.password!,
          );

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(returnedData.user!.uid)
          .set({
            'firstName': user.firstName,
            'lastName': user.lastName,
            'email': user.email,
          });

      return Right('User created successfully');
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }

      return Left(message);
    }
  }

  @override
  Future<Either> signin(UserSigninReq user) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email!,
        password: user.password!,
      );
      return Right('Signin successfull');
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'Invalid email or password';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      }

      return Left(message);
    }
  }

  @override
   Future<Either> forgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return const Right('Password reset email is sent');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found with this email address.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'Something went wrong. Please try again.';
      }
      return Left(message);
    } catch (e) {
      return const Left('An unexpected error occurred.');
    }
  }
  
  @override
  Future<bool> isLoggedIn() async {
    if (FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }
  

  @override
   Future<Either> getUser() async {
     try {
       var currentUser = FirebaseAuth.instance.currentUser;
       var userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.uid)
           .get().then((value) => value.data());
       return Right(userData);
     } catch (e) {
       return Left('Failed to fetch user data: ${e.toString()}');
     }
   }
}
 
