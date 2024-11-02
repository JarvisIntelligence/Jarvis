import 'package:isar/isar.dart';

part 'chat_messages.g.dart';

@Collection()
class SecureStorageData {
  Id id = Isar.autoIncrement; // Auto-increment ID
  @Index(unique: true)
  late String key;            // Storage key
  late String value;          // Encrypted value
}
