import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class SendMessage {
  List<Map<String, dynamic>> sendMessageBubbleChat(List<Map<String, dynamic>> userChat, String message) {
    // Get today's date
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";

    // Create a new message
    Map<String, dynamic> newMessage = {
      'isSender': true,
      'isStarred': false,
      'messageType': 'text',
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

    // Create a new copy of userChat to avoid direct mutation
    // List<Map<String, dynamic>> updatedUserChat = List<Map<String, dynamic>>.from(userChat);
    List<Map<String, dynamic>> updatedUserChat = [...userChat];

    // Check if the date already exists in the userChat list
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

  List<Map<String, dynamic>> sendLinkMessageBubbleChat(List<Map<String, dynamic>> userChat, String message) {
    // Get today's date
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";

    // Create a new message
    Map<String, dynamic> newMessage = {
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

    // Create a new copy of userChat to avoid direct mutation
    // List<Map<String, dynamic>> updatedUserChat = List<Map<String, dynamic>>.from(userChat);
    List<Map<String, dynamic>> updatedUserChat = [...userChat];

    // Check if the date already exists in the userChat list
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

  Future<Duration?> getAudioRecordingDuration(String filePath) async {
    Directory? appDocDirectory = await getExternalStorageDirectory();
    String dirPath = '${appDocDirectory?.path}/Media/Audio Recordings/Sent';

    final player = AudioPlayer();
    Duration? duration = await player.setUrl('$dirPath/$filePath');
    return duration;
  }

  List<Map<String, dynamic>> sendAudioMessageBubbleChat(List<Map<String, dynamic>> userChat, String filePath, Duration duration) {
    // Get today's date
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";
    // Create a new message
    Map<String, dynamic> newMessage = {
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

    // Create a new copy of userChat to avoid direct mutation
    // List<Map<String, dynamic>> updatedUserChat = List<Map<String, dynamic>>.from(userChat);
    List<Map<String, dynamic>> updatedUserChat = [...userChat];

    // Check if the date already exists in the userChat list
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

  List<Map<String, dynamic>> sendPhotoMessageBubbleChat(List<Map<String, dynamic>> userChat, File file, String imageName) {
    // Get today's date
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";
    // Create a new message
    Map<String, dynamic> newMessage = {
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

    // Create a new copy of userChat to avoid direct mutation
    // List<Map<String, dynamic>> updatedUserChat = List<Map<String, dynamic>>.from(userChat);
    List<Map<String, dynamic>> updatedUserChat = [...userChat];

    // Check if the date already exists in the userChat list
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

  List<Map<String, dynamic>> sendVideoMessageBubbleChat(List<Map<String, dynamic>> userChat, File file, String videoName) {
    // Get today's date
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";
    // Create a new message
    Map<String, dynamic> newMessage = {
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

    // Create a new copy of userChat to avoid direct mutation
    List<Map<String, dynamic>> updatedUserChat = [...userChat];

    // Check if the date already exists in the userChat list
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

  List<Map<String, dynamic>> sendMediaMessageBubbleChat(List<Map<String, dynamic>> userChat, File file, String imageName, String mediaType) {
    // Get today's date
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";
    // Create a new message
    Map<String, dynamic> newMessage = {
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

    // Create a new copy of userChat to avoid direct mutation
    // List<Map<String, dynamic>> updatedUserChat = List<Map<String, dynamic>>.from(userChat);
    List<Map<String, dynamic>> updatedUserChat = [...userChat];

    // Check if the date already exists in the userChat list
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

  List<Map<String, dynamic>> sendFileMessageBubbleChat(List<Map<String, dynamic>> userChat, String extension, String fileName, String size, String fileLogo) {
    // Get today's date
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";
    // Create a new message
    Map<String, dynamic> newMessage = {
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

    // Create a new copy of userChat to avoid direct mutation
    // List<Map<String, dynamic>> updatedUserChat = List<Map<String, dynamic>>.from(userChat);
    List<Map<String, dynamic>> updatedUserChat = [...userChat];

    // Check if the date already exists in the userChat list
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

  List<Map<String, dynamic>> addChatToUserChatList(
      List<Map<String, dynamic>> userChatList,
      String chatId, String userImage, String chatName,
      String lastMessage, String lastMessageTime, bool isGroup,
      String? userImage2, String numberOfUsers, String? userImage3,
      String groupImage)
  {
    // Create a new message
    Map<String, dynamic> newChat = {
      'notification': false,
      'id': chatId,
      'userImage': userImage,
      'name': chatName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'isGroup': false,
      'userImage2': userImage2,
      'numberOfUsers': numberOfUsers,
      'userImage3': userImage3,
      'groupImage': groupImage
    };

    // Create a new copy of userChat to avoid direct mutation
    List<Map<String, dynamic>> updatedUserChat = [...userChatList];

    updatedUserChat.add(newChat);

    return updatedUserChat;
  }


  String _getMonthName(int month) {
    List<String> monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
}
