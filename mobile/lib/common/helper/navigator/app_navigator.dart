import 'package:flutter/material.dart';

class AppNavigator {
  
  static void pushReplacement(BuildContext context, Widget widget) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

   static void push(BuildContext context, Widget widget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  /// Push [widget] and remove all previous routes from the navigation stack.
  /// Use this for navigation after logout so the user can't go back to
  /// authenticated screens using the back button.
  static void pushAndRemoveAll(BuildContext context, Widget widget) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => widget),
      (Route<dynamic> route) => false,
    );
  }

}