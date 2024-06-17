class SendMessage {
  List<Map<String, dynamic>> sendMessageBubbleChat(List<Map<String, dynamic>> userChat, String message) {
    // Get today's date
    DateTime today = DateTime.now();
    String formattedDate = "${_getMonthName(today.month)} ${today.day}, ${today.year}";

    // Create a new message
    Map<String, dynamic> newMessage = {
      'isSender': true,
      'isStarred': false,
      'time': today,
      'message': message,
      'senderName': "Me",
      'isDelivered': false,
      'isSent': false
    };

    // Create a new copy of userChat to avoid direct mutation
    // List<Map<String, dynamic>> updatedUserChat = List<Map<String, dynamic>>.from(userChat);
    List<Map<String, dynamic>> updatedUserChat = [...userChat];

    // Check if the date already exists in the userChat list
    bool dateExists = false;
    for (var chat in updatedUserChat) {
      if (chat.containsKey(formattedDate)) {
        chat[formattedDate]!.add(newMessage);
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

  String _getMonthName(int month) {
    List<String> monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
}
