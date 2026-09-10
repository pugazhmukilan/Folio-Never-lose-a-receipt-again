import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages encrypted storage for PASSWORD-type item fields.
/// Each field's value is stored under a unique key in the platform keystore
/// (Android Keystore / iOS Secure Enclave). The SQLite `value` column stores
/// only the key reference — never the plaintext.
class SecureFieldService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String prefix = 'kipt_field_';

  /// Stores [plaintext] for [fieldId] in the secure keystore.
  /// Returns the storage key reference to save in the DB.
  Future<String> storePassword(int fieldId, String plaintext) async {
    final key = '$prefix$fieldId';
    await _storage.write(key: key, value: plaintext);
    return key;
  }

  /// Reads the plaintext value for [fieldId]. Returns null if not found.
  Future<String?> readPassword(int fieldId) async {
    try {
      return await _storage.read(key: '$prefix$fieldId');
    } catch (_) {
      return null;
    }
  }

  /// Reads using an explicit key reference (as stored in item_fields.value).
  Future<String?> readPasswordByKey(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  /// Deletes the stored password for [fieldId].
  Future<void> deletePassword(int fieldId) async {
    try {
      await _storage.delete(key: '$prefix$fieldId');
    } catch (_) {
      // Silent — key may not exist
    }
  }

  /// Deletes passwords for multiple field IDs (e.g., when deleting an item).
  Future<void> deletePasswords(List<int> fieldIds) async {
    for (final id in fieldIds) {
      await deletePassword(id);
    }
  }

  /// Checks if a stored value exists for [fieldId].
  Future<bool> hasPassword(int fieldId) async {
    try {
      final val = await _storage.read(key: '$prefix$fieldId');
      return val != null;
    } catch (_) {
      return false;
    }
  }
}
