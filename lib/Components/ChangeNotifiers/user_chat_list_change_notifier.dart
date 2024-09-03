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

  Future<void> addItem({
    required String chatId,
    required String userImage,
    required String chatName,
    required String lastMessage,
    required String lastMessageTime,
    required bool isGroup,
    String? userImage2,
    required String numberOfUsers,
    String? userImage3,
    required String groupImage,
    required bool notification,
    required bool isPinned,
    required bool isArchived
  }) async {
    // Check if the item with the given chatId already exists
    int existingIndex = _items.indexWhere((item) => item['id'] == chatId);

    Map<String, dynamic> chatItem = {
      'notification': notification,
      'id': chatId,
      'userImage': userImage,
      'name': chatName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'isGroup': isGroup,
      'userImage2': userImage2,
      'numberOfUsers': numberOfUsers,
      'userImage3': userImage3,
      'groupImage': groupImage,
      'isPinned': isPinned,
      'isArchived': isArchived
    };

    Map<String, dynamic> chatItemDatabase = {
      'notification': notification ? 1 : 0,
      'id': chatId,
      'userImage': userImage,
      'name': chatName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'isGroup': isGroup ? 1 : 0,
      'userImage2': userImage2,
      'numberOfUsers': numberOfUsers,
      'userImage3': userImage3,
      'groupImage': groupImage,
      'isPinned': isPinned ? 1 : 0,
      'isArchived': isArchived ? 1 : 0
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
