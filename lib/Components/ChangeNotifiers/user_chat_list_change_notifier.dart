import 'package:flutter/material.dart';
import '../Utilities/encrypter.dart';

class UserChatListChangeNotifier extends ChangeNotifier {
  final SecureStorageHelper storage = SecureStorageHelper();
  List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get userChatList => _items;

  Future<void> loadInitialData() async {
    await _loadList();
  }

  Future<void> _loadList() async {
    List<Map<String, dynamic>>? storedList = await storage.readListData('userChatList');
    if (storedList != null) {
      _items = List<Map<String, dynamic>>.from(storedList);
      notifyListeners();
    }
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
    required bool notification
  }) async {
    // Check if the item with the given chatId already exists
    int existingIndex = _items.indexWhere((item) => item['id'] == chatId);
    if (existingIndex != -1) {
      // Update existing item
      _items[existingIndex]['lastMessage'] = lastMessage;
      _items[existingIndex]['lastMessageTime'] = lastMessageTime;
      _items[existingIndex]['notification'] = notification; // Set notification to true when updating
    } else {
      // Add new item
      Map<String, dynamic> newChat = {
        'notification': false,
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
      };
      _items.add(newChat);
    }
    await storage.saveListData('userChatList', _items);
    notifyListeners();
  }
}