import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';

class Friends {

  Future<bool> checkIfUserExists(String jwtToken, String name) async {
    String url = 'https://jarvis-backend-tqdw.onrender.com/friend/search?query=$name';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken'
        },
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if ((responseData['users'] as List).isEmpty){
        InAppNotifications.show(
            description: 'User does not exist',
            onTap: () {}
        );
        return false;
      } else {
        return true;
      }
    } catch (e) {
      InAppNotifications.show(
          description:
          'User check failed. A system error occurred while trying to check if the user exists.',
          onTap: () {}
      );
    }
    return false;
  }

  Future<String> addUserToFriendList(String jwtToken, String userName) async {
    String url = 'https://jarvis-backend-tqdw.onrender.com/friend/add';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken'
        },
        body: jsonEncode({
          'username': userName
        })
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        InAppNotifications.show(
            description:
            'User has been added',
            onTap: () {}
        );
        return responseData['friend_id'];
      } else {
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
          'Adding user failed. A system error occurred while trying to add the user to your friend list.',
          onTap: () {}
      );
    }
    return '';
  }

  Future<Map<String, dynamic>> retrieveFriendList(String jwtToken) async {
    String url = 'https://jarvis-backend-tqdw.onrender.com/friend/list';

    try {
      final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken'
          },
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else {
        final String errorMessage = responseData['message'];
        InAppNotifications.show(
            description:
            errorMessage,
            onTap: () {}
        );
      }
    } catch (e) {
      print(e);
      InAppNotifications.show(
          description:
          'User friend list retrieval failed. A system error occurred while trying to retrieve your friend list.',
          onTap: () {}
      );
    }
    return {};
  }

}