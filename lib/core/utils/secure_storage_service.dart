import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  SecureStorageService(this._secureStorage, this._prefs);

  // Secure Storage (for sensitive data like tokens)
  Future<void> writeSecure(String key, String value) async {
    print('DEBUG: Writing secure key: $key');
    await _secureStorage.write(key: key, value: value);
    print('DEBUG: Finished writing secure key: $key');
  }

  Future<String?> readSecure(String key) async {
    print('DEBUG: Reading secure key: $key');
    final value = await _secureStorage.read(key: key);
    print('DEBUG: Finished reading secure key: $key. Found: ${value != null}');
    return value;
  }

  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAllSecure() async {
    await _secureStorage.deleteAll();
  }

  // Shared Preferences (for non-sensitive data)
  Future<void> writeString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? readString(String key) {
    return _prefs.getString(key);
  }

  Future<void> writeBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? readBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> writeInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? readInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> writeDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? readDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? readJson(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
