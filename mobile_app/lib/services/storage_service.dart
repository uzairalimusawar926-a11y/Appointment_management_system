import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  final _secureStorage = const FlutterSecureStorage();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== General Storage ====================
  
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // ==================== Secure Storage ====================
  
  Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecureString(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // ==================== User Data ====================
  
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final userJson = jsonEncode(userData);
    await setString('user_data', userJson);
  }

  Map<String, dynamic>? getUserData() {
    final userJson = getString('user_data');
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  Future<void> clearUserData() async {
    await remove('user_data');
  }

  // ==================== Session ====================
  
  Future<void> saveSessionId(String sessionId) async {
    await setSecureString('session_id', sessionId);
  }

  Future<String?> getSessionId() async {
    return await getSecureString('session_id');
  }

  Future<void> clearSession() async {
    await deleteSecureString('session_id');
  }

  // ==================== Server URL ====================
  
  Future<void> saveServerUrl(String url) async {
    await setString('server_url', url);
  }

  String? getServerUrl() {
    return getString('server_url');
  }

  // ==================== Remember Me ====================
  
  Future<void> setRememberMe(bool value) async {
    await setBool('remember_me', value);
  }

  bool getRememberMe() {
    return getBool('remember_me') ?? false;
  }

  // ==================== Login Credentials (Secure) ====================
  
  Future<void> saveLoginCredentials(String email, String password) async {
    await setSecureString('saved_email', email);
    await setSecureString('saved_password', password);
  }

  Future<Map<String, String>?> getLoginCredentials() async {
    final email = await getSecureString('saved_email');
    final password = await getSecureString('saved_password');
    
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<void> clearLoginCredentials() async {
    await deleteSecureString('saved_email');
    await deleteSecureString('saved_password');
  }

  // ==================== App Settings ====================
  
  Future<void> setFirstTime(bool value) async {
    await setBool('first_time', value);
  }

  bool isFirstTime() {
    return getBool('first_time') ?? true;
  }

  // ==================== Company Logo Cache ====================
  
  Future<void> saveCompanyLogo(String logoBase64) async {
    await setString('company_logo', logoBase64);
  }

  String? getCompanyLogo() {
    return getString('company_logo');
  }

  Future<void> clearCompanyLogo() async {
    await remove('company_logo');
  }
}
