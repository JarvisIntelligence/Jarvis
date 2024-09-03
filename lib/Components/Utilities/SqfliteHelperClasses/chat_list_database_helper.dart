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
        'id': record['id'],
        'userImage': record['userImage'],
        'name': record['name'],
        'lastMessage': record['lastMessage'],
        'lastMessageTime': record['lastMessageTime'],
        'isGroup': record['isGroup'] == 1,
        'userImage2': record['userImage2'],
        'numberOfUsers': record['numberOfUsers'],
        'userImage3': record['userImage3'],
        'groupImage': record['groupImage'],
        'isPinned': record['isPinned'] == 1,
        'isArchived': record['isArchived'] == 1
      };
    }).toList();
  }

  Future<void> updateChat(Map<String, dynamic> chat) async {
    final db = await database;
    await db.update(
      'chatList',
      chat,
      where: 'id = ?',
      whereArgs: [chat['id']],
    );
  }

  Future<void> pinChats(Set<String> idsToUpdate) async {
    int numberOfPinnedChats = await ChatListDatabaseHelper().getNumberOfPinnedChats();
    final db = await database;

    const int maxPinnedChats = 3;
    int remainingSlots = maxPinnedChats - numberOfPinnedChats;

    // Get the first few IDs from the set, up to the number of remaining slots
    List<String> idsToPin = idsToUpdate.take(remainingSlots).toList();

    for (String id in idsToPin) {
      await db.update(
        'chatList',
        {'isPinned': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> unpinChats(Set<String> idsToUnpin) async {
    final db = await database;

    for (String id in idsToUnpin) {
      // Check if the chat is currently pinned
      List<Map<String, dynamic>> result = await db.query(
        'chatList',
        columns: ['isPinned'],
        where: 'id = ?',
        whereArgs: [id],
      );

      // If the chat is pinned (isPinned == 1), unpin it
      if (result.isNotEmpty && result.first['isPinned'] == 1) {
        await db.update(
          'chatList',
          {'isPinned': 0},
          where: 'id = ?',
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
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty || result.first['isPinned'] == 0) {
        // If any ID is not pinned, return false
        return false;
      }
    }

    // If all IDs are pinned, return true
    return true;
  }

  Future<void> archiveChats(Set<String> idsToUpdate) async {
    final db = await database;

    for (String id in idsToUpdate) {
      await db.update(
        'chatList',
        {'isArchived': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> unarchiveChats(Set<String> idsToUnarchive) async {
    final db = await database;

    for (String id in idsToUnarchive) {
      // Check if the chat is currently archived
      List<Map<String, dynamic>> result = await db.query(
        'chatList',
        columns: ['isArchived'],
        where: 'id = ?',
        whereArgs: [id],
      );

      // If the chat is archived (isArchived == 1), unarchive it
      if (result.isNotEmpty && result.first['isArchived'] == 1) {
        await db.update(
          'chatList',
          {'isArchived': 0},
          where: 'id = ?',
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
        'id': record['id'],
        'userImage': record['userImage'],
        'name': record['name'],
        'lastMessage': record['lastMessage'],
        'lastMessageTime': record['lastMessageTime'],
        'isGroup': record['isGroup'] == 1,
        'userImage2': record['userImage2'],
        'numberOfUsers': record['numberOfUsers'],
        'userImage3': record['userImage3'],
        'groupImage': record['groupImage'],
        'isPinned': false,
        'isArchived': record['isArchived'] == 1
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
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllChats() async {
    final db = await database;
    await db.delete('chatList');
  }
}
