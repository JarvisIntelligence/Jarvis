import 'package:sqflite/sqflite.dart';
import 'initialize_database.dart';

class ContactListDatabaseHelper {
  static final ContactListDatabaseHelper _instance = ContactListDatabaseHelper._internal();

  factory ContactListDatabaseHelper() => _instance;

  ContactListDatabaseHelper._internal();

  Future<Database> get database async {
    return await DatabaseProvider().database;
  }

  Future<List<Map<String, dynamic>>> getAllContacts() async {
    final db = await database;

    // Perform a join between contactList and chatList tables
    final List<Map<String, dynamic>> records = await db.rawQuery('''
    SELECT cl.*, 
           ch.isPinned AS isPinned, 
           ch.isArchived AS isArchived 
    FROM contactList AS cl
    LEFT JOIN chatList AS ch 
    ON cl.id = ch.id
    ORDER BY isPinned DESC, lastMessageTime DESC
  ''');

    // Map the result to the desired format with default values
    return records.map((record) {
      return {
        'userImage3': record['userImage3'],
        'numberOfUsers': record['numberOfUsers'],
        'isGroup': record['isGroup'] == 1,
        'userImage': record['userImage'],
        'userImage2': record['userImage2'],
        'name': record['name'],
        'groupImage': record['groupImage'],
        'id': record['id'],
        'userBio': record['userBio'],
        'isPinned': (record['isPinned'] as int? ?? 0) == 1,
        'isArchived': (record['isArchived'] as int? ?? 0) == 1
      };
    }).toList();
  }

  Future<void> insertContact(Map<String, dynamic> contact) async {
    final db = await database;
    await db.insert('contactList', contact, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateContact(Map<String, dynamic> contact) async {
    final db = await database;
    return await db.update(
      'contactList',
      contact,
      where: 'id = ?',
      whereArgs: [contact['id']],
    );
  }

  Future<int> deleteContact(String id) async {
    final db = await database;
    return await db.delete(
      'contactList',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllRecords() async {
    final db = await database;
    await db.delete('contactList', where: '1=1');
  }

  Future<void> dropTable() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS contactList');
  }
}
