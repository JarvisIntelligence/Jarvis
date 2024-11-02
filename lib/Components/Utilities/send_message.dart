import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SendMessage {
  final Uuid uuid = const Uuid();

  List<Map<String, dynamic>> _addMessageToUserChat(
      List<Map<String, dynamic>> userChat, String formattedDate, Map<String, dynamic> newMessage) {
    List<Map<String, dynamic>> updatedUserChat = [...userChat];

    bool dateExists = false;
    for (var chat in updatedUserChat) {
      if (chat.containsKey(formattedDate)) {
        chat[formattedDate].add(newMessage);
        dateExists = true;
        break;
      }
    }

    // If the date does not exist, create a new entry for the date
    if (!dateExists) {
      updatedUserChat.add({formattedDate: [newMessage]});
    }

    return updatedUserChat;
  }

  List<Map<String, dynamic>> sendNotificationMessage(List<Map<String, dynamic>> userChat) {
    DateTime today = DateTime.now();
    const String notificationMessageId = "notification_unread_message";
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";

    bool messageExists = userChat.any((message) => message['messageId'].toString() == notificationMessageId.toString());

    if(!messageExists){
      Map<String, dynamic> newMessage = {
        'messageId': notificationMessageId,
        'isSender': false,
        'isStarred': false,
        'messageType': 'notification',
        'fileName': '',
        'time': today.toString(),
        'message': 'You have unread message(s)',
        'senderName': 'System',
        'isDelivered': false,
        'isSent': false,
        'isSeen': false,
        'duration': (Duration.zero).toString(),
        'file': File(''),
        'extension': '',
        'size': '',
        'fileLogo': '',
      };
      return _addMessageToUserChat(userChat, formattedDate, newMessage);
    } else {
      return userChat;

    }
  }

  List<Map<String, dynamic>> sendMessageBubbleChat(List<Map<String, dynamic>> userChat, String message, bool isSender, String messageId, String senderName, DateTime? lastMessageTime) {
    DateTime today = DateTime.now();
    String formattedDate = '';
    if(lastMessageTime != null){
      formattedDate = "${_getMonthName(lastMessageTime.month)} ${lastMessageTime.day}, ${lastMessageTime.year}";
    } else {
      formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";
    }

    Map<String, dynamic> newMessage = {
      'messageId': messageId,
      'isSender': isSender,
      'isStarred': false,
      'messageType': 'text',
      'fileName': '',
      'time': lastMessageTime ?? today.toString(),
      'message': message,
      'senderName': senderName,
      'isDelivered': false,
      'isSent': false,
      'isSeen': false,
      'duration': (Duration.zero).toString(),
      'file': File(''),
      'extension': '',
      'size': '',
      'fileLogo': '',
    };

    return _addMessageToUserChat(userChat, formattedDate, newMessage);
  }

  List<Map<String, dynamic>> sendLinkMessageBubbleChat(List<Map<String, dynamic>> userChat, String message) {
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";

    Map<String, dynamic> newMessage = {
      'messageId': uuid.v4(),
      'isSender': true,
      'isStarred': false,
      'messageType': 'link',
      'fileName': '',
      'time': today.toString(),
      'message': message,
      'senderName': "Me",
      'isDelivered': false,
      'isSent': false,
      'isSeen': false,
      'duration': (Duration.zero).toString(),
      'file': File(''),
      'extension': '',
      'size': '',
      'fileLogo': '',
    };

    return _addMessageToUserChat(userChat, formattedDate, newMessage);
  }

  Future<Duration?> getAudioRecordingDuration(String filePath) async {
    Directory? appDocDirectory = await getExternalStorageDirectory();
    String dirPath = '${appDocDirectory?.path}/Media/Audio Recordings/Sent';

    final player = AudioPlayer();
    Duration? duration = await player.setUrl('$dirPath/$filePath');
    return duration;
  }

  List<Map<String, dynamic>> sendAudioMessageBubbleChat(List<Map<String, dynamic>> userChat, String filePath, Duration duration) {
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";

    Map<String, dynamic> newMessage = {
      'messageId': uuid.v4(),
      'isSender': true,
      'isStarred': false,
      'messageType': 'audio',
      'message': '',
      'fileName': filePath,
      'time': today.toString(),
      'senderName': "Me",
      'isDelivered': false,
      'isSent': false,
      'isSeen': false,
      'duration': duration.toString(),
      'file': File(''),
      'extension': '',
      'size': '',
      'fileLogo': '',
    };

    return _addMessageToUserChat(userChat, formattedDate, newMessage);
  }

  List<Map<String, dynamic>> sendMediaMessageBubbleChat(List<Map<String, dynamic>> userChat, File file, String imageName, String mediaType) {
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";

    Map<String, dynamic> newMessage = {
      'messageId': uuid.v4(),
      'isSender': true,
      'isStarred': false,
      'messageType': (mediaType == 'Pictures') ? 'image' : 'video',
      'message': '',
      'fileName': imageName,
      'time': today.toString(),
      'senderName': "Me",
      'isDelivered': false,
      'isSent': false,
      'isSeen': false,
      'duration': (Duration.zero).toString(),
      'file': file,
      'extension': '',
      'size': '',
      'fileLogo': '',
    };

    return _addMessageToUserChat(userChat, formattedDate, newMessage);
  }

  List<Map<String, dynamic>> sendPhotoMessageBubbleChat(List<Map<String, dynamic>> userChat, File file, String imageName) {
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";

    Map<String, dynamic> newMessage = {
      'messageId': uuid.v4(),
      'isSender': true,
      'isStarred': false,
      'messageType': 'image',
      'message': '',
      'fileName': imageName,
      'time': today.toString(),
      'senderName': "Me",
      'isDelivered': false,
      'isSent': false,
      'isSeen': false,
      'duration': (Duration.zero).toString(),
      'file': file,
      'extension': '',
      'size': '',
      'fileLogo': '',
    };

    return _addMessageToUserChat(userChat, formattedDate, newMessage);
  }

  List<Map<String, dynamic>> sendVideoMessageBubbleChat(List<Map<String, dynamic>> userChat, File file, String videoName) {
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";

    Map<String, dynamic> newMessage = {
      'messageId': uuid.v4(),
      'isSender': true,
      'isStarred': false,
      'messageType': 'video',
      'message': '',
      'fileName': videoName,
      'time': today.toString(),
      'senderName': "Me",
      'isDelivered': false,
      'isSent': false,
      'isSeen': false,
      'duration': (Duration.zero).toString(),
      'file': file,
      'extension': '',
      'size': '',
      'fileLogo': '',
    };

    return _addMessageToUserChat(userChat, formattedDate, newMessage);
  }

  List<Map<String, dynamic>> sendFileMessageBubbleChat(
      List<Map<String, dynamic>> userChat, String extension, String fileName, String size, String fileLogo) {
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";

    Map<String, dynamic> newMessage = {
      'messageId': uuid.v4(),
      'isSender': true,
      'isStarred': false,
      'messageType': 'file',
      'message': '',
      'fileName': fileName,
      'time': today.toString(),
      'senderName': "Me",
      'isDelivered': false,
      'isSent': false,
      'isSeen': false,
      'duration': (Duration.zero).toString(),
      'file': File(''),
      'extension': extension,
      'size': size,
      'fileLogo': fileLogo,
    };

    return _addMessageToUserChat(userChat, formattedDate, newMessage);
  }

  String _getMonthName(int month) {
    List<String> monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
}
