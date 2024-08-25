import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactListDatabaseHelper {
  static final ContactListDatabaseHelper _instance = ContactListDatabaseHelper._internal();
  static Database? _database;

  factory ContactListDatabaseHelper() {
    return _instance;
  }

  ContactListDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'userDataBase.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS contactList ('
              'id TEXT PRIMARY KEY, '
              'userImage TEXT, '
              'userImage2 TEXT, '
              'userImage3 TEXT, '
              'numberOfUsers TEXT, '
              'isGroup INTEGER, '
              'name TEXT, '
              'groupImage TEXT, '
              'userBio TEXT'
              ')',
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllContacts() async {
    final db = await database;

    final List<Map<String, dynamic>> records = await db.query('contactList');

    // Convert integer to boolean for each record
    return records.map((record) {
      return {
        'userImage3': record['userImage3'],
        'numberOfUsers': record['numberOfUsers'],
        'isGroup': record['isGroup'] == 1, // Convert integer to boolean
        'userImage': record['userImage'],
        'userImage2': record['userImage2'],
        'name': record['name'],
        'groupImage': record['groupImage'],
        'id': record['id'],
        'userBio': record['userBio']
      };
    }).toList();
  }

  Future<void> insertContact(Map<String, dynamic> contact) async {
    final db = await database;
    await db.insert('contactList', contact);
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
    await db.delete(
      'contactList',
      where: '1=1', // This condition is always true, so all records are deleted
    );
  }

  Future<void> dropTable() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS contactList');
  }
}

