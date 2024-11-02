// import 'dart:convert';
//
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DatabaseProvider {
//   static final DatabaseProvider _instance = DatabaseProvider._internal();
//   static Database? _database;
//
//   factory DatabaseProvider() {
//     return _instance;
//   }
//
//   DatabaseProvider._internal();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   final storage = const FlutterSecureStorage();
//
//   Future<Database> _initDatabase() async {
//     String? userData = await storage.read(key: 'user_data');
//     String userID;
//
//     if (userData != null) {
//       Map<String, dynamic> details = jsonDecode(userData);
//       userID = details['userID'];
//     } else {
//       userID = 'appDatabase';
//     }
//
//     String path = join(await getDatabasesPath(), '$userID.db');
//
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         // Create all tables here
//         db.execute(
//           'CREATE TABLE contactList ('
//               'id TEXT PRIMARY KEY, '
//               'userImage TEXT, '
//               'userImage2 TEXT, '
//               'userImage3 TEXT, '
//               'numberOfUsers TEXT, '
//               'isGroup INTEGER, '
//               'name TEXT, '
//               'groupImage TEXT, '
//               'userBio TEXT'
//               ')',
//         );
//         db.execute(
//           'CREATE TABLE chatList ('
//               'id TEXT PRIMARY KEY, '
//               'notification INTEGER, '
//               'userImage TEXT, '
//               'name TEXT, '
//               'lastMessage TEXT, '
//               'lastMessageTime TEXT, '
//               'isGroup INTEGER, '
//               'userImage2 TEXT, '
//               'numberOfUsers TEXT, '
//               'userImage3 TEXT, '
//               'groupImage TEXT, '
//               'isPinned INTEGER, '
//               'isArchived INTEGER'
//               ')',
//         );
//       },
//     );
//   }
//
//   Future<void> closeDatabase() async {
//     if (_database != null) {
//       await _database!.close();
//       _database = null; // Reset to null so it can be re-initialized later
//     }
//   }
// }

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../extras.dart';

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

  final storage = const FlutterSecureStorage();

  Future<Database> _initDatabase() async {
    String? userID = await Extras().retrieveUserID();
    // String userID;

    if(userID == '') {
      userID = 'appDatabase';
    }

    String path = join(await getDatabasesPath(), '$userID.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE contactList ('
              'conversationId TEXT PRIMARY KEY, '
              'userImage TEXT, '
              'userImage2 TEXT, '
              'userImage3 TEXT, '
              'numberOfUsers TEXT, '
              'isGroup INTEGER, '
              'name TEXT, '
              'userName TEXT, '
              'groupImage TEXT, '
              'userBio TEXT, '
              'participantsId TEXT'
              ')',
        );
        db.execute(
          'CREATE TABLE chatList ('
              'conversationId TEXT PRIMARY KEY, '
              'notification INTEGER, '
              'userImage TEXT, '
              'name TEXT, '
              'userName TEXT, '
              'lastMessage TEXT, '
              'lastMessageTime TEXT, '
              'isGroup INTEGER, '
              'userImage2 TEXT, '
              'numberOfUsers TEXT, '
              'userImage3 TEXT, '
              'groupImage TEXT, '
              'isPinned INTEGER, '
              'isArchived INTEGER, '
              'participantsId TEXT'
              ')',
        );
      },
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

