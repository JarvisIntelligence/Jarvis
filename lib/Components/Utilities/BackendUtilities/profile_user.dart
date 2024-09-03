import 'dart:convert';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:http/http.dart' as http;

class ProfileUser{
  Future<Map<String, dynamic>> retrieveProfileDetails(String jwtToken, String userID, bool isAtLoginPage) async {
    String url = 'https://jarvis-backend-tqdw.onrender.com/profile/$userID';

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
      if(!isAtLoginPage){
        InAppNotifications.show(
            description:
            'Login failed. A system error occurred while trying to log you in.',
            onTap: () {}
        );
      }
    }
    return {};
  }

  Future<bool> updateProfileDetails(String jwtToken, String typeName, String value) async {
    String url = 'https://jarvis-backend-tqdw.onrender.com/profile/update';
    String field;

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