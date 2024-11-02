import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jarvis_app/Components/ChangeNotifiers/new_message_notifier.dart';
import 'package:jarvis_app/Components/Utilities/BackendUtilities/register_login_user.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../../ChangeNotifiers/user_chat_list_change_notifier.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import '../SqfliteHelperClasses/chat_list_database_helper.dart';
import '../encrypter.dart';
import '../extras.dart';
import '../send_message.dart';

class SendReceiveMessages{
  final SecureStorageHelper secureStorageHelper = SecureStorageHelper();

  Future<String> createConversationBackend (List<String> participantsID, String accessToken) async {
    const String url = 'https://staging.jarvisintelligence.com/chat/start';
    try{
      final createConversationResponse = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode({
          "participants": participantsID,
        })
      );
      final responseBody = jsonDecode(createConversationResponse.body);
      if (createConversationResponse.statusCode == 200) {
        String chatId = responseBody['data']['conversation_id'];
        return chatId;
      } else {
        if (await handleTokenExpiry(responseBody)) return '';
        InAppNotifications.show(
          description: "We couldn't create your conversation. Please try again.",
          onTap: () {},
        );
      }
    } catch(e) {
      InAppNotifications.show(
        description: "We couldn't create your conversation. Please try again.",
        onTap: () {},
      );
    }
    return '';
  }

  Future<bool> sendMessageBackend(String accessToken, String message, String conversationId) async {
    const String url = 'https://staging.jarvisintelligence.com/chat/messages';
    try{
      final sendMessageBackendResponse = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
          body: jsonEncode({
            "text": message,
            "conversation_id": conversationId,
          })
      );
      final responseBody = jsonDecode(sendMessageBackendResponse.body);
      if (sendMessageBackendResponse.statusCode == 201) {
        return true;
      } else {
        if (await handleTokenExpiry(responseBody)) return false;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<List<dynamic>> retrieveConversations(String accessToken, String userId) async {
    const String url = 'https://staging.jarvisintelligence.com/chat/conversations';
    try {
      final retrieveConversationResponse = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseBody = jsonDecode(retrieveConversationResponse.body);

      if (retrieveConversationResponse.statusCode == 200) {
        List<dynamic> conversations = responseBody['data'];
        return conversations;
      } else {
        if (await handleTokenExpiry(responseBody)) return [];
        InAppNotifications.show(
          description: "We couldn't retrieve your conversations. Please try again.",
          onTap: () {},
        );
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  Future<List<dynamic>> getMessagesForConversation(String conversationId) async {
    String url = 'https://staging.jarvisintelligence.com/chat/messages/$conversationId';
    try {
      final retrieveConversationResponse = await http.get(
        Uri.parse(url),
      );

      final responseBody = jsonDecode(retrieveConversationResponse.body);

      if (retrieveConversationResponse.statusCode == 200) {
        List<dynamic> messages = responseBody['data'];
        return messages;
      } else {
        if (await handleTokenExpiry(responseBody)) return [];
        InAppNotifications.show(
          description: "We couldn't retrieve your conversations. Please try again.",
          onTap: () {},
        );
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  Future<void> addConversationsToChatList(
      List<String> participantsId,
      String conversationId,
      String conversationType,
      String chatId,
      String accessToken,
      String userId,
      String message,
      bool isSender,
      DateTime lastMessageTime,
      BuildContext context,
      bool isOldMessage,
      String chatName,
      String profileImage,
      String userName,
      List<String> images,
      ) async {

    // Add the item to the chat list with explicit named parameters
    Provider.of<UserChatListChangeNotifier>(context, listen: false).addItem(
      conversationId: conversationId,
      userImage: conversationType == 'group' ? images[0] : profileImage,
      chatName: chatName,
      userName: conversationType == 'group' ? conversationId : userName,
      lastMessage: message,
      lastMessageTime: lastMessageTime.toString(),
      isGroup: conversationType == 'group',
      userImage2: conversationType == 'group' ? images[1] : '',
      numberOfUsers: participantsId.length.toString(),
      userImage3: conversationType == 'group' ? images[2] : '',
      groupImage: '',
      notification: (message != '' && !isSender && !isOldMessage) ? true : false,
      isPinned: false,
      isArchived: false,
      participantsId: participantsId.join(","),
      oldConversationId: conversationId,
    );
  }

  Future<Map<String, dynamic>> retrieveChatDetails (String conversationType, List<String> participantsId, String userId) async {
    String chatName = '';
    String profileImage = '';
    String userName = '';
    List<String> images = List.filled(3, '');
    List<String> otherParticipants = participantsId.where((id) => id != userId).toList();

    // Retrieve profile information for non-group chats
    if (conversationType != 'group') {
      var profile = await retrieveFriendProfile(otherParticipants.first, await Extras().retrieveJWT());
      chatName = profile['chatName'] ?? '';
      profileImage = profile['profileImage'] ?? '';
      userName = profile['userName'] ?? '';
    } else {
      // Group chat logic
      List<String> participantNames = [];

      await Future.wait(participantsId.map((friendID) async {
        if (friendID.isNotEmpty) {
          var profile = await SendReceiveMessages()
              .retrieveFriendProfile(friendID, await Extras().retrieveJWT());

          String profileImage = profile['profileImage'] ?? '';
          String fullName = profile['chatName'] ?? '';

          if (participantNames.length < 3) {
            images[participantNames.length] = profileImage;
          }
          participantNames.add(fullName.split(' ').first);
        }
      }));

      if (participantNames.length > 3) {
        chatName = '${participantNames[0]}, ${participantNames[1]}, ${participantNames[2]}, and others';
      } else if (participantNames.length == 3) {
        chatName = '${participantNames[0]}, ${participantNames[1]}, and ${participantNames[2]}';
      } else if (participantNames.length == 2) {
        chatName = '${participantNames[0]} and ${participantNames[1]}';
      } else {
        chatName = participantNames.join(', ');
      }
    }

    return {
      'chatName': chatName,
      'profileImage': profileImage,
      'userName': userName,
      'images': images
    };
  }

  void retrieveOldConversationsFromBackend(String conversationId, BuildContext context, String conversationType, String chatName, List<String> participantsId, String userId) async {
    List<dynamic> messages = await getMessagesForConversation(conversationId);
    final SecureStorageHelper secureStorageHelper = SecureStorageHelper();

    Map<String, dynamic> chatDetails = await retrieveChatDetails(conversationType, participantsId, userId);

    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];
      String dateString = message['time_sent'];
      DateTime parsedDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(dateString);
      String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(parsedDate);
      DateTime lastMessageTime = DateTime.parse(formattedDate);

      List<Map<String, dynamic>>? tempUserChat = await secureStorageHelper.readListData(conversationId);

      await Provider.of<NewMessageNotifier>(context, listen: false).sendMessageAndUpdateChat(
        conversationId: message['conversation_id'],
        tempUserChat: tempUserChat,
        message: message['text'],
        messageId: message['_id'],
        senderId: message['sender'],
        accessToken: await Extras().retrieveJWT(),
        lastMessageTime: lastMessageTime,
      );

      await addConversationsToChatList(
          participantsId,
          conversationId,
          conversationType,
          chatName,
          await Extras().retrieveJWT(),
          userId,
          message['text'],
          message['sender'] == await Extras().retrieveUserID(),
          lastMessageTime,
          context,
          true,
          chatDetails['chatName'],
          chatDetails['profileImage'],
          chatDetails['userName'],
          chatDetails['images']
      );
    }
  }

  Future<void> addingConversations(
      String accessToken,
      String userId,
      Map<String, dynamic> data,
      BuildContext context
      ) async {
    final List<dynamic> conversations = await retrieveConversations(accessToken, userId);

    for (var conversation in conversations) {
      String conversationId = conversation['_id'];
      String conversationType = conversation['conversation_type'];
      List<String> participantsId = List<String>.from(conversation['participants']);
      List<String> otherParticipants = participantsId.where((id) => id != userId).toList();
      String chatName = otherParticipants.join(", ");
      String message = '';
      DateTime lastMessageTime = DateTime.now();

      bool shouldAddToChatList = true;

      if (data.isNotEmpty && data['data']['conversation_id'] == conversationId) {
        addingUpdatingNewMessageFromSocket(conversationId, conversationType, participantsId, message, chatName, lastMessageTime, context, data);
      } else if (data.isEmpty) {
        chatMessagesAndListInitialization(conversationId, conversationType, context, shouldAddToChatList, chatName, participantsId, message, lastMessageTime);
      }
    }
  }

  void addingUpdatingNewMessageFromSocket (String conversationId, String conversationType, List<String> participantsId, String message, String chatName, DateTime lastMessageTime, BuildContext context, Map<String, dynamic> data) async {
    List<Map<String, dynamic>>? tempUserChat = await secureStorageHelper.readListData(conversationId);
    String accessToken = await Extras().retrieveJWT();
    String userId = await Extras().retrieveUserID();
    message = data['data']['text'];
    bool isSender = data['data']['sender'] == userId;

    if (!isSender) {
      await Provider.of<NewMessageNotifier>(context, listen: false).addNotificationMessage(
        conversationId: conversationId,
        tempUserChat: tempUserChat,
      );
      await Provider.of<NewMessageNotifier>(context, listen: false).sendMessageAndUpdateChat(
        conversationId: conversationId,
        tempUserChat: tempUserChat,
        message: message,
        messageId: data['data']['_id'],
        senderId: data['data']['sender'],
        accessToken: accessToken,
      );
    }
    List<Map<String, dynamic>>? userChat = await secureStorageHelper.readListData(conversationId);
    if (userChat != null) {
      Map<String, dynamic> lastMessageAndTime = Extras().getLastMessage(userChat, conversationType == 'group');
      message = lastMessageAndTime['message'];
    }
    Map<String, dynamic> chatDetails = await retrieveChatDetails(conversationType, participantsId, userId);
    await addConversationsToChatList(participantsId, conversationId, conversationType, chatName, accessToken, userId, message, isSender, lastMessageTime, context, false, chatDetails['chatName'], chatDetails['profileImage'], chatDetails['userName'], chatDetails['images']);
  }

  Future<void> chatMessagesAndListInitialization(String conversationId, String conversationType, BuildContext context, bool shouldAddToChatList, String chatName, List<String> participantsId, String message, DateTime lastMessageTime) async {
    List<Map<String, dynamic>>? userChat = await secureStorageHelper.readListData(conversationId);
    String accessToken = await Extras().retrieveJWT();
    String userId = await Extras().retrieveUserID();

    if (userChat != null && userChat.isNotEmpty) {
      Map<String, dynamic> lastMessageAndTime = Extras().getLastMessage(userChat, conversationType == 'group');
      message = lastMessageAndTime['message'];
      var time = lastMessageAndTime['time'];
      if (time is String) {
        lastMessageTime = DateTime.parse(time);
      } else if (time is DateTime) {
        lastMessageTime = time;
      }
    } else {
      retrieveOldConversationsFromBackend(conversationId, context, conversationType, chatName, participantsId, userId);
      shouldAddToChatList = false;
    }
    if (shouldAddToChatList) {
      Map<String, dynamic> chatDetails = await retrieveChatDetails(conversationType, participantsId, userId);
      await addConversationsToChatList(participantsId, conversationId, conversationType, chatName, accessToken, userId, message, false, lastMessageTime, context, false, chatDetails['chatName'],
      chatDetails['profileImage'],
      chatDetails['userName'],
      chatDetails['images']);
    }
  }

  Future<Map<String, String>> retrieveFriendProfile(String userId, String accessToken) async {
    String url = "https://jarvis-backend-tqdw.onrender.com/profile/$userId";
    String chatName = '';
    String profileImage = '';
    String bio = '';
    String userName = '';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        chatName = responseData['profile']['fullname'];
        bio = responseData['profile']['biography'];
        userName = responseData['profile']['username'];
        if (responseData['profile']['profilepicture'] != null) {
          profileImage = responseData['profile']['profilepicture'];
        }
      }
    } catch (e) {
      print(e);
    }
    return {'chatName': chatName, 'profileImage': profileImage, 'bio': bio, 'userName': userName};
  }

  // Future<void> startBackgroundService() async {
  //   final service = FlutterBackgroundService();
  //
  //   await service.configure(
  //     androidConfiguration: AndroidConfiguration(
  //       onStart: onStart,
  //       isForegroundMode: true,
  //       autoStart: true,
  //     ),
  //     iosConfiguration: IosConfiguration(
  //       onForeground: onStart,
  //       onBackground: (_) => false, // iOS doesn't support background tasks for sockets
  //     ),
  //   );
  //   await service.startService();
  // }
  //
  // void onStart(ServiceInstance service) async {
  //   final accessToken = await Extras().retrieveJWT();
  //   final userId = await Extras().retrieveUserID();
  //   connectToSocket(accessToken, userId);
  // }

  Future<void> connectToSocket(String accessToken, String userId, BuildContext context) async {
    final socket = IO.io(
      'https://staging.jarvisintelligence.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    // Establish connection to the server
    socket.connect();

    // Listen for connection events
    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on('message', (data) {
      addingConversations(accessToken, userId, data, context);
    });

    // Listen for disconnection events
    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });

    // Error handling
    socket.on('connect_error', (error) {
      print('Connection error: $error');
    });
  }

  Future<bool> handleTokenExpiry(Map<String, dynamic> responseBody) async {
    if (responseBody['msg'] == 'Token has expired') {
      await RegisterLoginUser().logOutUser();
      return true;
    }
    return false;
  }

  }