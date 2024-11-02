import 'package:flutter/foundation.dart';
import 'package:jarvis_app/Components/Utilities/BackendUtilities/send_receive_messages.dart';

import '../Utilities/encrypter.dart';
import '../Utilities/extras.dart';
import '../Utilities/send_message.dart';

class NewMessageNotifier extends ChangeNotifier {
  final SecureStorageHelper secureStorageHelper = SecureStorageHelper();

  void notifyChanges() {
    notifyListeners();
  }

  Future<void> sendMessageAndUpdateChat({
    required String conversationId,
    required List<Map<String, dynamic>>? tempUserChat,
    required String message,
    required String messageId,
    required String senderId,
    required String accessToken,
    DateTime? lastMessageTime
  }) async {
    List<Map<String, dynamic>> updatedUserChat = SendMessage().sendMessageBubbleChat(
      tempUserChat ?? [],
      message,
        (senderId == await Extras().retrieveUserID()),
      messageId,
      (await SendReceiveMessages().retrieveFriendProfile(senderId, accessToken))['chatName'] ?? '',
      lastMessageTime
    );
    await secureStorageHelper.saveListData(conversationId, updatedUserChat);
    notifyChanges();
  }

  Future<void> addNotificationMessage({
    required String conversationId,
    required List<Map<String, dynamic>>? tempUserChat,
  }) async {
    List<Map<String, dynamic>> updatedUserChat = SendMessage().sendNotificationMessage(
      tempUserChat ?? [],
    );
    await secureStorageHelper.saveListData(conversationId, updatedUserChat);
    notifyChanges();
  }

  Future<void> deleteMessageById({
    required String conversationId,
    required List<Map<String, dynamic>>? tempUserChat,
    required String messageId,
  }) async {
    List<Map<String, dynamic>> updatedUserChat = List.from(tempUserChat ?? []);
    for (var entry in updatedUserChat) {
      entry.forEach((date, messages) {
        if (messages is List) {
          messages.removeWhere((message) => message['messageId'].toString() == messageId);
        }
      });
    }
    await secureStorageHelper.saveListData(conversationId, updatedUserChat);
    notifyChanges();
  }
}

