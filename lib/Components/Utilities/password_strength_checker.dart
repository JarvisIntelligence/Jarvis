import 'package:flutter/material.dart';

class PasswordStrengthChecker {
  String calculatePasswordStrength(String password) {
    //Length Check: Ensure the password is at least 8 characters long.
    // Uppercase Check: Ensure the password contains at least one uppercase letter.
    // Lowercase Check: Ensure the password contains at least one lowercase letter.
    // Number Check: Ensure the password contains at least one number.
    // Special Character Check: Ensure the password contains at least one special character (e.g., !@#\$%^&*).

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    switch (strength) {
      case 0:
      case 1:
        return "Very Weak";
      case 2:
        return "Weak";
      case 3:
        return "Moderate";
      case 4:
        return "Strong";
      case 5:
        return "Very Strong";
      default:
        return "Unknown";
    }
  }

  Color getIndicatorColor(String strength) {
    switch (strength) {
      case "Very Strong":
        return Colors.green;
      case "Strong":
        return Colors.blue;
      case "Moderate":
        return Colors.orange;
      case "Weak":
      case "Very Weak":
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  int getNumberOfIndicator(String strength) {
    switch (strength) {
      case "Very Weak":
        return 1;
      case "Weak":
        return 2;
      case "Moderate":
        return 3;
      case "Strong":
        return 4;
      case "Very Strong":
        return 5;
      default:
        return 0;
    }
  }

}