import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Extras{
  final storage = const FlutterSecureStorage();

  String capitalize(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<String> retrieveJWT() async {
    String? jsonString = await storage.read(key: 'user_data');
    if (jsonString != null){
      Map<String, dynamic> userLoggedInData = jsonDecode(jsonString);
      return userLoggedInData['jwt_token'];
    }
    return '';
  }

  Future<String> retrieveUserID() async {
    String? jsonString = await storage.read(key: 'user_data');
    if (jsonString != null){
      Map<String, dynamic> userLoggedInData = jsonDecode(jsonString);
      return userLoggedInData['userID'];
    }
    return '';
  }

  Future<String> retrieveUsername() async {
    String? jsonString = await storage.read(key: 'user_data');
    if (jsonString != null) {
      Map<String, dynamic> userLoggedInData = jsonDecode(jsonString);
      return userLoggedInData['userName'];
    }
    return '';
  }

  Map<String, dynamic> getLastMessage(List<Map<String, dynamic>> userChat, bool isGroup) {
    if (userChat.isEmpty) return {};

    // Get the last date's key by accessing the last entry in userChat
    String lastDateKey = userChat.last.keys.last;

    // Get the list of messages for the last date
    List<Map<String, dynamic>> messages = List<Map<String, dynamic>>.from(userChat.last[lastDateKey]);

    if (messages.isEmpty) return {};

    // Get the last message
    Map<String, dynamic> lastMessage = messages.last;
    late String message;
    String senderName = lastMessage['senderName'];

    if (isGroup) {
      if (lastMessage['message'] != '') {
        message = '$senderName: ${lastMessage['message']}';
      } else {
        message = (lastMessage['messageType'] == 'audio') ? '$senderName: Audio Recording' : (lastMessage['messageType'] == 'image') ? '$senderName: Image' : (lastMessage['messageType'] == 'video') ? '$senderName: Video' : '$senderName: File';
      }
    } else {
      if (lastMessage['message'] != '') {
        message = lastMessage['message'];
      } else {
        message = (lastMessage['messageType'] == 'audio') ? 'Audio Recording' : (lastMessage['messageType'] == 'image') ? 'Image' : (lastMessage['messageType'] == 'video') ? 'Video' : 'File';
      }
    }

    return {
      'message': message,
      'time': lastMessage['time'],
    };
  }

  String encodeUrl(String url) {
    return Uri.encodeComponent(url.trim());
  }

}