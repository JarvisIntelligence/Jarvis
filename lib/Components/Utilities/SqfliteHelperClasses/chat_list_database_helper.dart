import 'package:sqflite/sqflite.dart';
import 'initialize_database.dart';

class ChatListDatabaseHelper {
  static final ChatListDatabaseHelper _instance = ChatListDatabaseHelper._internal();

  factory ChatListDatabaseHelper() => _instance;

  ChatListDatabaseHelper._internal();

  Future<Database> get database async {
    return await DatabaseProvider().database;
  }

  Future<void> insertChat(Map<String, dynamic> chat) async {
    final db = await database;
    await db.insert(
      'chatList',
      chat,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllChats() async {
    final db = await database;
    final List<Map<String, dynamic>> records = await db.rawQuery('''
      SELECT * FROM chatList
      WHERE isArchived != 1
      ORDER BY isPinned DESC, lastMessageTime DESC
    ''');

    return records.map((record) {
      return {
        'notification': record['notification'] == 1,
        'conversationId': record['conversationId'],
        'userImage': record['userImage'],
        'name': record['name'],
        'userName': record['userName'],
        'lastMessage': record['lastMessage'],
        'lastMessageTime': record['lastMessageTime'],
        'isGroup': record['isGroup'] == 1,
        'userImage2': record['userImage2'],
        'numberOfUsers': record['numberOfUsers'],
        'userImage3': record['userImage3'],
        'groupImage': record['groupImage'],
        'isPinned': record['isPinned'] == 1,
        'isArchived': record['isArchived'] == 1,
        'participantsId': record['participantsId']
      };
    }).toList();
  }

  Future<void> updateChat(Map<String, dynamic> chat) async {
    final db = await database;
    await db.update(
      'chatList',
      chat,
      where: 'conversationId = ?',
      whereArgs: [chat['conversationId']],
    );
  }

  Future<void> pinChats(Set<String> idsToUpdate) async {
    int numberOfPinnedChats = await getNumberOfPinnedChats();
    final db = await database;

    const int maxPinnedChats = 3;
    int remainingSlots = maxPinnedChats - numberOfPinnedChats;

    List<String> idsToPin = idsToUpdate.take(remainingSlots).toList();

    for (String id in idsToPin) {
      await db.update(
        'chatList',
        {'isPinned': 1},
        where: 'conversationId = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> unpinChats(Set<String> idsToUnpin) async {
    final db = await database;

    for (String id in idsToUnpin) {
      List<Map<String, dynamic>> result = await db.query(
        'chatList',
        columns: ['isPinned'],
        where: 'conversationId = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty && result.first['isPinned'] == 1) {
        await db.update(
          'chatList',
          {'isPinned': 0},
          where: 'conversationId = ?',
          whereArgs: [id],
        );
      }
    }
  }

  Future<bool> areAllSelectedChatsPinned(Set<String> isAllIdsPinned) async {
    final db = await database;

    for (String id in isAllIdsPinned) {
      List<Map<String, dynamic>> result = await db.query(
        'chatList',
        columns: ['isPinned'],
        where: 'conversationId = ?',
        whereArgs: [id],
      );

      if (result.isEmpty || result.first['isPinned'] == 0) {
        return false;
      }
    }

    return true;
  }

  Future<void> archiveChats(Set<String> idsToUpdate) async {
    final db = await database;

    for (String id in idsToUpdate) {
      await db.update(
        'chatList',
        {'isArchived': 1},
        where: 'conversationId = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> unarchiveChats(Set<String> idsToUnarchive) async {
    final db = await database;

    for (String id in idsToUnarchive) {
      List<Map<String, dynamic>> result = await db.query(
        'chatList',
        columns: ['isArchived'],
        where: 'conversationId = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty && result.first['isArchived'] == 1) {
        await db.update(
          'chatList',
          {'isArchived': 0},
          where: 'conversationId = ?',
          whereArgs: [id],
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getAllArchivedChats() async {
    final db = await database;
    final List<Map<String, dynamic>> records = await db.rawQuery('''
      SELECT * FROM chatList
      WHERE isArchived == 1
      ORDER BY isPinned DESC, lastMessageTime DESC
    ''');

    return records.map((record) {
      return {
        'notification': record['notification'] == 1,
        'conversationId': record['conversationId'],
        'userImage': record['userImage'],
        'name': record['name'],
        'userName': record['userName'],
        'lastMessage': record['lastMessage'],
        'lastMessageTime': record['lastMessageTime'],
        'isGroup': record['isGroup'] == 1,
        'userImage2': record['userImage2'],
        'numberOfUsers': record['numberOfUsers'],
        'userImage3': record['userImage3'],
        'groupImage': record['groupImage'],
        'isPinned': false,
        'isArchived': record['isArchived'] == 1,
        'participantsId': record['participantsId']
      };
    }).toList();
  }

  Future<int> getNumberOfPinnedChats() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM chatList
      WHERE isPinned = 1
    ''');

    final int pinnedCount = Sqflite.firstIntValue(result) ?? 0;
    return pinnedCount;
  }

  Future<int> getNumberOfArchivedChats() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM chatList
      WHERE isArchived = 1
    ''');

    final int archivedCount = Sqflite.firstIntValue(result) ?? 0;
    return archivedCount;
  }

  Future<void> deleteChat(String id) async {
    final db = await database;
    await db.delete(
      'chatList',
      where: 'conversationId = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllChats() async {
    final db = await database;
    await db.delete('chatList');
  }

  Future<int> updateConversationId(String oldConversationId, String newConversationId) async {
    final db = await database;

    return await db.update(
      'chatList',
      {'conversationId': newConversationId}, // Update to the new conversationId
      where: 'conversationId = ?',
      whereArgs: [oldConversationId],
    );
  }

  Future<String?> getConversationIdByUserName(String userName) async {
    final db = await database;

    // Query the contactList table for a contact with the specified userName
    final List<Map<String, dynamic>> result = await db.query(
      'chatList',
      columns: ['conversationId'],
      where: 'userName = ?',
      whereArgs: [userName],
      limit: 1, // Limit the results to one, as we only need one match
    );

    if (result.isNotEmpty) {
      return result.first['conversationId'] as String?;
    } else {
      return null;
    }
  }

}

