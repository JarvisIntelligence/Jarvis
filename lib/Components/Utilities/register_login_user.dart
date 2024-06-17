import 'dart:convert';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:http/http.dart' as http;


class RegisterLoginUser {
  Future<bool> registerUser(Map<String, dynamic> jsonData) async {
    const String url = 'https://jarvis-backend-tqdw.onrender.com/auth/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonData),
      );
      if (response.statusCode == 201) {
        InAppNotifications.show(
            description:
            'Account created successfully',
            onTap: () {}
        );
        return true;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String errorMessage = responseData['message'];
         InAppNotifications.show(
              description:
              errorMessage,
              onTap: () {}
          );
      }
    } catch (e) {
      InAppNotifications.show(
        description:
        'Registration failed. A system error occurred while registering.',
        onTap: () {}
      );
      print('Error: $e');
    }
    return false;
  }

  Future<bool> logInUser(Map<String, dynamic> jsonData) async {
    const String url = 'https://jarvis-backend-tqdw.onrender.com/auth/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonData),
      );
      if (response.statusCode == 200) {
        InAppNotifications.show(
            description:
            'Login successful',
            onTap: () {}
        );
        return true;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String errorMessage = responseData['message'];
        InAppNotifications.show(
            description:
            errorMessage,
            onTap: () {}
        );
      }
    } catch (e) {
      InAppNotifications.show(
          description:
          'Registration failed. A system error occurred while registering.',
          onTap: () {}
      );
      print('Error: $e');
    }
    return false;
  }
}