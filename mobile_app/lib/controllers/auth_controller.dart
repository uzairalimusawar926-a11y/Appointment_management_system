import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';

class AuthController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthController() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final userData = _storageService.getUserData();
      final sessionId = await _storageService.getSessionId();
      
      if (userData != null && sessionId != null) {
        _currentUser = User.fromJson(userData);
        _isAuthenticated = true;
        _apiService.setSessionId(sessionId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _setLoading(true);
    _clearError();

    try {
      // Use Odoo's built-in authentication endpoint
      final response = await _apiService.post(
        '/web/session/authenticate',
        {
          'db': ApiConfig.database,
          'login': email,
          'password': password,
        },
      );

      if (response.success && response.data != null) {
        final uid = response.data['uid'];
        
        // Check if authentication was successful
        if (uid != null && uid != false) {
          // Get session ID from cookies (automatically stored by ApiService)
          final sessionId = _apiService.getSessionId();
          
          // Extract timezone from user_context
          final userContext = response.data['user_context'];
          final timezone = userContext != null && userContext['tz'] != false 
              ? userContext['tz'] 
              : 'UTC';

          // Create user object from response
          _currentUser = User(
            id: uid,
            name: response.data['name'] ?? response.data['username'] ?? email,
            email: email,
            login: response.data['username'] ?? email,
            partnerId: response.data['partner_id'],
            companyId: response.data['company_id'],
            companyName: response.data['company_name'],
            timezone: timezone,
            sessionId: sessionId,
          );
          
          _isAuthenticated = true;

          // Prepare user data for storage
          final userDataToSave = {
            'id': uid,
            'name': _currentUser!.name,
            'email': email,
            'login': _currentUser!.login,
            'partner_id': _currentUser!.partnerId,
            'company_id': _currentUser!.companyId,
            'company_name': _currentUser!.companyName,
            'timezone': timezone,
            'db': response.data['db'],
          };

          // Save user data
          await _storageService.saveUserData(userDataToSave);

          // Save session ID if available
          if (sessionId != null) {
            await _storageService.saveSessionId(sessionId);
          }

          // Handle remember me
          await _storageService.setRememberMe(rememberMe);
          if (rememberMe) {
            await _storageService.saveLoginCredentials(email, password);
          } else {
            await _storageService.clearLoginCredentials();
          }

          _setLoading(false);
          notifyListeners();
          
          debugPrint('✅ Login successful for user: ${_currentUser!.name}');
          return true;
        } else {
          _setError('Invalid credentials');
          _setLoading(false);
          return false;
        }
      } else {
        _setError(response.error ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _setError('An error occurred during login: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        ApiConfig.signupEndpoint,
        {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'db': ApiConfig.database,
        },
      );

      _setLoading(false);

      if (response.success) {
        debugPrint('✅ Signup successful');
        return true;
      } else {
        _setError(response.error ?? 'Signup failed');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Signup error: $e');
      _setError('An error occurred during signup: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      // Call logout API
      await _apiService.post('/web/session/destroy', {});
      debugPrint('✅ Logout API called');
    } catch (e) {
      debugPrint('Error during logout API call: $e');
    }

    // Clear local data
    _currentUser = null;
    _isAuthenticated = false;
    _apiService.clearSession();
    
    await _storageService.clearUserData();
    await _storageService.clearSession();
    
    // Keep server URL but clear credentials if remember me is false
    if (!_storageService.getRememberMe()) {
      await _storageService.clearLoginCredentials();
    }

    _setLoading(false);
    notifyListeners();
    
    debugPrint('✅ Logout successful');
  }

  Future<bool> checkAuthentication() async {
    if (!_isAuthenticated) {
      debugPrint('❌ Not authenticated');
      return false;
    }

    try {
      // Check if session is still valid
      final response = await _apiService.post('/web/session/get_session_info', {});
      
      if (response.success && response.data != null) {
        final uid = response.data['uid'];
        if (uid != null && uid != false) {
          debugPrint('✅ Session is valid');
          return true;
        }
      }
      
      // Session expired, logout
      debugPrint('❌ Session expired');
      await logout();
      return false;
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    if (_storageService.getRememberMe()) {
      return await _storageService.getLoginCredentials();
    }
    return null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Helper method to check if user is authenticated
  bool get hasValidSession {
    return _isAuthenticated && 
           _currentUser != null && 
           _apiService.isAuthenticated();
  }
}