import 'dart:convert';
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

  static Future<encrypt.Key> _getOrGenerateKey(FlutterSecureStorage secureStorage) async {
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
    final jsonData = jsonEncode(data.map((map) {
      final updatedMap = Map<String, dynamic>.from(map);
      updatedMap.forEach((key, value) {
        if (value is DateTime) {
          updatedMap[key] = value.toIso8601String();
        }
      });
      return updatedMap;
    }).toList());

    await saveData(key, jsonData);
  }

  Future<List<Map<String, dynamic>>?> readListData(String key) async {
    final jsonData = await readData(key);
    if (jsonData == null) return null;

    final List<dynamic> decoded = jsonDecode(jsonData);
    return decoded.map((item) {
      final map = Map<String, dynamic>.from(item);
      map.forEach((key, value) {
        if (value is String && DateTime.tryParse(value) != null) {
          map[key] = DateTime.parse(value);
        }
      });
      return map;
    }).toList();
  }
}
