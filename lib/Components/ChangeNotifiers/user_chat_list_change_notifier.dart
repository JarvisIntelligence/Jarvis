import 'package:flutter/material.dart';
import 'package:jarvis_app/Components/Utilities/SqfliteHelperClasses/chat_list_database_helper.dart';

class UserChatListChangeNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _itemsDatabase = [];

  List<Map<String, dynamic>> archivedChatItems = [];
  List<Map<String, dynamic>> archivedChatItemsDatabase = [];

  List<Map<String, dynamic>> get userChatList => _items;
  List<Map<String, dynamic>> get userArchivedChatsList => archivedChatItems;


  Future<void> loadInitialData() async {
    await loadList();
    await loadArchivedChatList();
  }

  Future<void> loadList() async {
    final List<Map<String, dynamic>> chatList = await ChatListDatabaseHelper().getAllChats();
    _items = chatList;
    _itemsDatabase = List.from(chatList); // Sync _itemsDatabase with loaded data
    notifyListeners();
  }

  Future<void> loadArchivedChatList() async {
    final List<Map<String, dynamic>> chatList = await ChatListDatabaseHelper().getAllArchivedChats();
    archivedChatItems = chatList;
    archivedChatItemsDatabase = List.from(chatList); // Sync _itemsDatabase with loaded data
    notifyListeners();
  }

  Future<void> disableNotification(String conversationId) async {
    int chatIndex = _items.indexWhere((item) => item['conversationId'] == conversationId);

    if (chatIndex != -1) {
      _items[chatIndex]['notification'] = false;
      _itemsDatabase[chatIndex]['notification'] = false;

      await ChatListDatabaseHelper().updateChat({
        'conversationId': conversationId,
        'notification': 0,
      });

      notifyListeners();
    }
  }

  Future<void> addItem({
    required String conversationId,
    required String oldConversationId,
    required String userImage,
    required String chatName,
    required String userName,
    required String lastMessage,
    required String lastMessageTime,
    required bool isGroup,
    String? userImage2,
    required String numberOfUsers,
    String? userImage3,
    required String groupImage,
    required bool notification,
    required bool isPinned,
    required bool isArchived,
    required String participantsId,
  }) async {
    // If oldConversationId is the same as conversationId, skip the replacement logic
    if (oldConversationId != conversationId) {
      int oldIndex = _items.indexWhere((item) => item['conversationId'] == oldConversationId);

      if (oldIndex != -1) {
        // Replace oldConversationId with conversationId
        _items[oldIndex]['conversationId'] = conversationId;
        _itemsDatabase[oldIndex]['conversationId'] = conversationId;

        // Update in the database with the new conversationId
        await ChatListDatabaseHelper().updateConversationId(oldConversationId, conversationId);
      }
    }

    // Check if the current conversationId exists
    int existingIndex = _items.indexWhere((item) => item['conversationId'] == conversationId);

    Map<String, dynamic> chatItem = {
      'notification': notification,
      'conversationId': conversationId,
      'userImage': userImage,
      'name': chatName,
      'userName': userName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'isGroup': isGroup,
      'userImage2': userImage2,
      'numberOfUsers': numberOfUsers,
      'userImage3': userImage3,
      'groupImage': groupImage,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'participantsId': participantsId,
    };

    Map<String, dynamic> chatItemDatabase = {
      'notification': notification ? 1 : 0,
      'conversationId': conversationId,
      'userImage': userImage,
      'name': chatName,
      'userName': userName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'isGroup': isGroup ? 1 : 0,
      'userImage2': userImage2,
      'numberOfUsers': numberOfUsers,
      'userImage3': userImage3,
      'groupImage': groupImage,
      'isPinned': isPinned ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
      'participantsId': participantsId,
    };

    if (existingIndex != -1) {
      // Update existing item
      _items[existingIndex] = chatItem;
      _itemsDatabase[existingIndex] = chatItemDatabase;
      await ChatListDatabaseHelper().updateChat(chatItemDatabase);
    } else {
      // Add new item
      _items.add(chatItem);
      _itemsDatabase.add(chatItemDatabase);
      await ChatListDatabaseHelper().insertChat(chatItemDatabase);
    }

    notifyListeners();
  }

}
