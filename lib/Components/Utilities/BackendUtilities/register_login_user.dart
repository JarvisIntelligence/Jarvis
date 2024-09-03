import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:jarvis_app/Components/Utilities/BackendUtilities/profile_user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class RegisterLoginUser {
  Future<Map<String, dynamic>> registerAndCreateProfile(Map<String, dynamic> jsonData) async {
    const String registerUrl = 'https://jarvis-backend-tqdw.onrender.com/auth/register';
    const String profileUrl = 'https://jarvis-backend-tqdw.onrender.com/profile/create';

    String fullname = jsonData['fullname'];
    List<String> nameParts = fullname.split(' ');

    // Determine profile picture name
    String profileName;
    if (nameParts.length >= 2) {
      // Use first and last name if there are at least two parts
      profileName = '${nameParts[0]} ${nameParts[1]}';
    } else {
      // Use the single name if there's only one part
      profileName = fullname;
    }

    try {
      // Register the user
      final registerResponse = await http.post(
        Uri.parse(registerUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonData),
      );

      if (registerResponse.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(registerResponse.body);
        String userId = responseData['user']['id'];
        Map<String, dynamic>? userDetails = await logInUser({
          'username': jsonData['username'],
          'password': jsonData['password']
        }, true);
        String? accessToken = userDetails?['accessToken'];

        // If registration is successful, create the user profile
        final profileResponse = await http.post(
          Uri.parse(profileUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
          body: jsonEncode({
            "profilepicture": "https://ui-avatars.com/api/?name=${Uri.encodeComponent(profileName)}&background=random",
            "biography": "Exploring this app, excited to connect and discover more!",
          }),
        );

        if (profileResponse.statusCode == 201) {
          // Profile creation successful
          InAppNotifications.show(
            description: 'Account created successfully',
            onTap: () {},
          );
          Map<String, dynamic> userDetails = {
            'userID': userId,
            'accessToken': accessToken
          };
          return userDetails;
        } else {
          // Profile creation failed, handle the error
          final Map<String, dynamic> responseData = jsonDecode(profileResponse.body);
          final String errorMessage = responseData['message'];
          InAppNotifications.show(
            description: errorMessage,
            onTap: () {},
          );
        }
      } else {
        // Registration failed, handle the error
        final Map<String, dynamic> responseData = jsonDecode(registerResponse.body);
        final String errorMessage = responseData['message'];
        InAppNotifications.show(
          description: errorMessage,
          onTap: () {},
        );
      }
    } catch (e) {
      InAppNotifications.show(
        description: 'Registration failed. A system error occurred.',
        onTap: () {},
      );
    }
    return {};
  }

  Future<Map<String, dynamic>?> googleAuth(String idToken) async {
    const String url = 'https://jarvis-backend-tqdw.onrender.com/auth/google_sign_in';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idToken': idToken,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String accessToken = responseData['access_token'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
        Map<String, dynamic> userDetails = {
          'userID': decodedToken['sub']['_id'],
          'accessToken': accessToken
        };
        InAppNotifications.show(
            description:
            'You have successfully logged in',
            onTap: () {}
        );
        return userDetails;
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
          'Google Authentication failed. Please try again later',
          onTap: () {}
      );
    }
    return {};
  }

  Future<void> signInGoogleAuth(Function updateProgressVisible, Function handleGoogleSignIn, Function storeUserDetailsSecureStorage, BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    updateProgressVisible();

    try {
      Map<String, dynamic>? googleDetails = await handleGoogleSignIn();
      Map<String, dynamic>? userDetails = await RegisterLoginUser().googleAuth(googleDetails?['idToken']);

      String accessToken = userDetails?['accessToken'];
      String userID = userDetails?['userID'];

      Map<String, dynamic> profileDetails = await ProfileUser().retrieveProfileDetails(userDetails?['accessToken'], userDetails?['userID'], true);

      if(profileDetails.isEmpty){
        await RegisterLoginUser().createUserProfile(accessToken, googleDetails?['photoUrl']);
      }

      await storeUserDetailsSecureStorage(accessToken, userID);
      if (context.mounted) {
        context.go('/homepage');
      }
    } catch (e) {
      InAppNotifications.show(
          description:
          'An error occurred: $e',
          onTap: (){}
      );
    } finally {
      updateProgressVisible();
    }
  }

  Future<bool> createUserProfile (String accessToken, String photoUrl) async {
    const String profileUrl = 'https://jarvis-backend-tqdw.onrender.com/profile/create';

    try {
      final profileResponse = await http.post(
        Uri.parse(profileUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode({
          "profilepicture": photoUrl,
          "biography": "Exploring this app, excited to connect and discover more!",
        }),
      );
      if (profileResponse.statusCode == 201) {
        return true;
      }
    } catch(e) {
      InAppNotifications.show(
        description: 'Profile creation failed.',
        onTap: () {},
      );
    }

    return false;
  }

  Future<Map<String, dynamic>?> logInUser(Map<String, dynamic> jsonData, bool isAutomaticLogin) async {
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
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String accessToken = responseData['access_token'];
        if (!isAutomaticLogin){
          Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
          Map<String, dynamic> userDetails = {
            'userID': decodedToken['sub']['_id'],
            'accessToken': accessToken
          };
          InAppNotifications.show(
              description:
              'Login successful',
              onTap: () {}
          );
          return userDetails;
        }
        return {'accessToken': accessToken};
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String errorMessage = responseData['message'];
        if(!isAutomaticLogin){
          InAppNotifications.show(
              description:
              errorMessage,
              onTap: () {}
          );
        }
      }
    } catch (e) {
      if(!isAutomaticLogin){
        InAppNotifications.show(
            description:
            'Login failed. A system error occurred while trying to log you in.',
            onTap: () {}
        );
      }
    }
    return null;
  }
}