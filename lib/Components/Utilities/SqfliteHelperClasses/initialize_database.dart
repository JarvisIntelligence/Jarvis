import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  static Database? _database;

  factory DatabaseProvider() {
    return _instance;
  }

  DatabaseProvider._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'appDataBase.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // Create all tables here
        db.execute(
          'CREATE TABLE contactList ('
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
        db.execute(
          'CREATE TABLE chatList ('
              'id TEXT PRIMARY KEY, '
              'notification INTEGER, '
              'userImage TEXT, '
              'name TEXT, '
              'lastMessage TEXT, '
              'lastMessageTime TEXT, '
              'isGroup INTEGER, '
              'userImage2 TEXT, '
              'numberOfUsers TEXT, '
              'userImage3 TEXT, '
              'groupImage TEXT, '
              'isPinned INTEGER, '
              'isArchived INTEGER'
              ')',
        );
      },
    );
  }
}
