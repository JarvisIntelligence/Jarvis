import 'dart:convert';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ProfileUser{
  Future<bool> checkInternetConnection(String message) async {
    bool isNetworkOn = await InternetConnectionChecker().hasConnection;
    if(!isNetworkOn){
      InAppNotifications.show(
          description: "Please check your internet connection, $message at the moment",
          onTap: (){}
      );
    }
    return isNetworkOn;
  }

  Future<Map<String, dynamic>> retrieveProfileDetails(String jwtToken, String userID, bool isAtLoginPage) async {
    String url = 'https://jarvis-backend-tqdw.onrender.com/profile/$userID';
    bool isNetworkOn = await checkInternetConnection("we can't retrieve your profile details");

    if(!isNetworkOn){
      return {};
    }
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken'
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        if(!isAtLoginPage){
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String errorMessage = responseData['message'];
          InAppNotifications.show(
              description:
              errorMessage,
              onTap: () {}
          );
        }
      }
    } catch (e) {
      print('cause of error: $e');
      if(!isAtLoginPage){
        InAppNotifications.show(
            description:
            'Login failed. A system error occurred while trying to retrieve your profile details.',
            onTap: () {}
        );
      }
    }
    return {};
  }

  Future<bool> updateProfileDetails(String jwtToken, String typeName, String value) async {
    String url = 'https://jarvis-backend-tqdw.onrender.com/profile/update';
    String field;

    bool isNetworkOn = await checkInternetConnection("we can't update your profile details");

    if(!isNetworkOn){
      return false;
    }

    switch(typeName) {
      case 'Name':
        field = 'fullname';
        break;
      case 'Email':
        field = 'email';
        break;
      case 'Bio':
        field = 'biography';
        break;
      case 'ProfilePicture':
        field = 'profilepicture';
      default:
        field = '';
        break;
    }

    try{
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken'
        },
        body: jsonEncode({
          field: value
        })
      );
      if(response.statusCode == 200) {
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
    } catch(e) {
      InAppNotifications.show(
          description:
          'User profile update failed. A system error occurred while trying to update your profile details.',
          onTap: () {}
      );
    }
    return false;
  }
}