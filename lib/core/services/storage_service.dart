import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staffpulseapp/core/configs/constants.dart';

/// Abstract contract for local persistent storage.
///
/// Decouples the application from concrete storage implementations
/// (SharedPreferences, Hive, Isar, or secure storage), making it trivial to
/// switch or augment storage backends without changing business logic.
abstract class IStorageService {
  Future<void> saveString(String key, String value);
  String? getString(String key);

  Future<void> saveBool(String key, bool value);
  bool? getBool(String key);

  Future<void> saveInt(String key, int value);
  int? getInt(String key);

  Future<void> saveJson(String key, Map<String, dynamic> jsonMap);
  Map<String, dynamic>? getJson(String key);

  Future<void> remove(String key);
  Future<void> clearAll();

  // Authentication & Session helpers
  Future<void> saveToken(String token);
  String? getToken();
  Future<void> removeToken();

  Future<void> saveCredentials({
    required String username,
    required String password,
    required bool rememberMe,
  });
  ({String? username, String? password, bool rememberMe}) getSavedCredentials();
  Future<void> clearSavedCredentials();
}

/// Production implementation of [IStorageService] powered by [SharedPreferences].
/// Handles JSON serialization, token lifecycles, and user credentials.
class StorageService implements IStorageService {
  final SharedPreferences prefs;

  StorageService({required this.prefs});

  @override
  Future<void> saveString(String key, String value) async {
    await prefs.setString(key, value);
  }

  @override
  String? getString(String key) {
    return prefs.getString(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  @override
  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  @override
  Future<void> saveInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  @override
  int? getInt(String key) {
    return prefs.getInt(key);
  }

  @override
  Future<void> saveJson(String key, Map<String, dynamic> jsonMap) async {
    final rawJson = jsonEncode(jsonMap);
    await prefs.setString(key, rawJson);
  }

  @override
  Map<String, dynamic>? getJson(String key) {
    final rawJson = prefs.getString(key);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) return decoded;
      return Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  @override
  Future<void> clearAll() async {
    await prefs.clear();
  }

  // --- Auth & Session ---

  @override
  Future<void> saveToken(String token) async {
    await prefs.setString(AppConstants.storageTokenKey, token);
  }

  @override
  String? getToken() {
    return prefs.getString(AppConstants.storageTokenKey);
  }

  @override
  Future<void> removeToken() async {
    await prefs.remove(AppConstants.storageTokenKey);
  }

  @override
  Future<void> saveCredentials({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    await prefs.setBool(AppConstants.storageRememberMeKey, rememberMe);
    if (rememberMe) {
      await prefs.setString(AppConstants.storageSavedUsernameKey, username);
      await prefs.setString(AppConstants.storageSavedPasswordKey, password);
    } else {
      await prefs.remove(AppConstants.storageSavedUsernameKey);
      await prefs.remove(AppConstants.storageSavedPasswordKey);
    }
  }

  @override
  ({String? username, String? password, bool rememberMe}) getSavedCredentials() {
    final rememberMe = prefs.getBool(AppConstants.storageRememberMeKey) ?? false;
    final username = prefs.getString(AppConstants.storageSavedUsernameKey);
    final password = prefs.getString(AppConstants.storageSavedPasswordKey);
    return (username: username, password: password, rememberMe: rememberMe);
  }

  @override
  Future<void> clearSavedCredentials() async {
    await prefs.remove(AppConstants.storageRememberMeKey);
    await prefs.remove(AppConstants.storageSavedUsernameKey);
    await prefs.remove(AppConstants.storageSavedPasswordKey);
  }
}
