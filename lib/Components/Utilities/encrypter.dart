import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureStorageHelper {
  static final SecureStorageHelper _instance = SecureStorageHelper._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final encrypt.Key _key;
  late final encrypt.Encrypter _encrypter;

  SecureStorageHelper._internal() {
    _initialize();
  }

  factory SecureStorageHelper() {
    return _instance;
  }

  Future<void> _initialize() async {
    _key = await _getOrGenerateKey(_secureStorage);
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }

  static Future<encrypt.Key> _getOrGenerateKey(
      FlutterSecureStorage secureStorage) async {
    String? keyString = await secureStorage.read(key: 'encryption_key');
    if (keyString == null) {
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      final keyBase64 = base64UrlEncode(keyBytes);
      await secureStorage.write(key: 'encryption_key', value: keyBase64);
      keyString = keyBase64;
    }
    return encrypt.Key.fromBase64(keyString);
  }

  String encryptData(String data) {
    final iv = encrypt.IV.fromLength(16);
    final encrypted = _encrypter.encrypt(data, iv: iv);
    final combined = iv.bytes + encrypted.bytes;
    return base64UrlEncode(combined);
  }

  String decryptData(String encryptedData) {
    final decoded = base64Url.decode(encryptedData);
    final iv = encrypt.IV(decoded.sublist(0, 16));
    final ciphertext = decoded.sublist(16);
    final decrypted = _encrypter.decrypt(encrypt.Encrypted(ciphertext), iv: iv);
    return decrypted;
  }

  Future<void> saveData(String key, String data) async {
    final encryptedData = encryptData(data);
    await _secureStorage.write(key: key, value: encryptedData);
  }

  Future<String?> readData(String key) async {
    final encryptedData = await _secureStorage.read(key: key);
    if (encryptedData == null) return null;
    return decryptData(encryptedData);
  }

  Future<void> deleteData(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  Future<void> saveListData(String key, List<Map<String, dynamic>> data) async {
    String jsonData = jsonEncode(data, toEncodable: (dynamic value) {
      if (value is File) {
        return value.path; // Convert File object to its path
      }
      return value.toString(); // Handle other non-serializable types if needed
    });
    await saveData(key, jsonData);
  }

  Future<List<Map<String, dynamic>>?> readListData(String key) async {
    final jsonData = await readData(key); // Your function to read the JSON string
    if (jsonData == null) return null;

    final List<dynamic> decoded = jsonDecode(jsonData);
    return decoded.map((item) {
      final map = Map<String, dynamic>.from(item);

      // Traverse through the nested structure to convert paths back to File objects
      map.forEach((date, messages) {
        if (messages is List) {
          for (var message in messages) {
            if (message is Map<String, dynamic> && message.containsKey('file')) {
              final filePath = message['file'];
              if (filePath is String) {
                message['file'] = File(filePath);
              }
            }
          }
        }
      });

      return map;
    }).toList();
  }
}


// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:isar/isar.dart';
// import 'package:encrypt/encrypt.dart' as encrypt;
// import '../Utilities/IsarDatabaseModels/chat_messages.dart';
// import 'package:path_provider/path_provider.dart';
//
// class SecureStorageHelper {
//   static final SecureStorageHelper _instance = SecureStorageHelper._internal();
//   late final encrypt.Key _key;
//   late final encrypt.Encrypter _encrypter;
//   static Isar? _isar; // Nullable to initialize lazily
//   // late final Isar _isar;
//   bool isInitialized = false;
//
//   SecureStorageHelper._internal();
//
//   factory SecureStorageHelper() {
//     return _instance;
//   }
//
//   Future<void> initialize() async {
//     if (isInitialized) {
//       return;
//     }
//
//     final directory = await getApplicationDocumentsDirectory();
//     _isar ??= await Isar.open(
//         [SecureStorageDataSchema],
//         directory: directory.path,
//     );
//
//     _key = await _getOrGenerateKey();
//     _encrypter = encrypt.Encrypter(encrypt.AES(_key));
//     print(_key);
//     print(_encrypter);
//     isInitialized = true;
//   }
//
//   Future<encrypt.Key> _getOrGenerateKey() async {
//     final keyEntry = await _isar?.secureStorageDatas.where().keyEqualTo('encryption_key').findFirst();
//     String? keyString = keyEntry?.value;
//     if (keyString == null) {
//       final random = Random.secure();
//       final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
//       final keyBase64 = base64UrlEncode(keyBytes);
//       await saveData('encryption_key', keyBase64);
//       keyString = keyBase64;
//     }
//     return encrypt.Key.fromBase64(keyString);
//   }
//
//   Future<void> ensureInitialized() async {
//     if (!isInitialized) {
//       await initialize();
//     }
//   }
//
//   String encryptData(String data) {
//     final iv = encrypt.IV.fromLength(16);
//     final encrypted = _encrypter.encrypt(data, iv: iv);
//     final combined = iv.bytes + encrypted.bytes;
//     return base64UrlEncode(combined);
//   }
//
//   String decryptData(String encryptedData) {
//     final decoded = base64Url.decode(encryptedData);
//     final iv = encrypt.IV(decoded.sublist(0, 16));
//     final ciphertext = decoded.sublist(16);
//     return _encrypter.decrypt(encrypt.Encrypted(ciphertext), iv: iv);
//   }
//
//   Future<void> saveData(String key, String data) async {
//     await ensureInitialized();
//     final encryptedData = encryptData(data);
//     final newEntry = SecureStorageData()
//       ..key = key
//       ..value = encryptedData;
//
//     await _isar?.writeTxn(() async {
//       await _isar?.secureStorageDatas.put(newEntry);
//     });
//   }
//
//   Future<String?> readData(String key) async {
//     await ensureInitialized();
//     final dataEntry = await _isar?.secureStorageDatas.where().keyEqualTo(key).findFirst();
//     if (dataEntry == null) return null;
//     return decryptData(dataEntry.value);
//   }
//
//   Future<void> deleteData(String key) async {
//     await ensureInitialized();
//     final dataEntry = await _isar?.secureStorageDatas.where().keyEqualTo(key).findFirst();
//     if (dataEntry != null) {
//       await _isar?.writeTxn(() async {
//         await _isar?.secureStorageDatas.delete(dataEntry.id);
//       });
//     }
//   }
//
//   Future<void> deleteAll() async {
//     await ensureInitialized();
//     await _isar?.writeTxn(() async {
//       await _isar?.secureStorageDatas.clear();
//     });
//   }
//
//   Future<void> saveListData(String key, List<Map<String, dynamic>> data) async {
//     print(key);
//     await ensureInitialized();
//     String jsonData = jsonEncode(data, toEncodable: (dynamic value) {
//       if (value is File) {
//         return value.path; // Convert File object to its path
//       }
//       return value.toString(); // Handle other non-serializable types if needed
//     });
//     print(key);
//     print(jsonData);
//     await saveData(key, jsonData);
//   }
//
//   Future<List<Map<String, dynamic>>?> readListData(String key) async {
//     await ensureInitialized();
//     final jsonData = await readData(key);
//     if (jsonData == null) return null;
//
//     final List<dynamic> decoded = jsonDecode(jsonData);
//     return decoded.map((item) {
//       final map = Map<String, dynamic>.from(item);
//
//       // Traverse through the nested structure to convert paths back to File objects
//       map.forEach((date, messages) {
//         if (messages is List) {
//           for (var message in messages) {
//             if (message is Map<String, dynamic> && message.containsKey('file')) {
//               final filePath = message['file'];
//               if (filePath is String) {
//                 message['file'] = File(filePath);
//               }
//             }
//           }
//         }
//       });
//
//       return map;
//     }).toList();
//   }
// }


