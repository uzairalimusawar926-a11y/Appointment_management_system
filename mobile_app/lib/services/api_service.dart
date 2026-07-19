import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final String? error;
  final String? errorCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'],
      error: json['error'],
      errorCode: json['error_code'],
    );
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _sessionId;
  Map<String, String> _cookies = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  void initialize() {
    try {
      developer.log('🔧 Initializing API Service with base URL: ${ApiConfig.baseUrl}');
      
      _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectionTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            // Accept all status codes to handle them manually
            return status != null && status < 500;
          },
        ),
      );

      // Add interceptors for logging and session management
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            developer.log('📤 REQUEST[${options.method}] => ${options.path}');
            if (options.data != null) {
              developer.log('Request Data: ${options.data}');
            }
            
            // Add cookies to request headers
            if (_cookies.isNotEmpty) {
              final cookieString = _cookies.entries
                  .map((e) => '${e.key}=${e.value}')
                  .join('; ');
              options.headers['Cookie'] = cookieString;
              developer.log('🍪 Sending cookies: $cookieString');
            }
            
            return handler.next(options);
          },
          onResponse: (response, handler) {
            developer.log('📥 RESPONSE[${response.statusCode}] => ${response.requestOptions.path}');
            
            // Extract and store cookies from response
            final setCookieHeader = response.headers['set-cookie'];
            if (setCookieHeader != null && setCookieHeader.isNotEmpty) {
              _parseCookies(setCookieHeader);
              developer.log('🍪 Cookies received and stored');
            }
            
            return handler.next(response);
          },
          onError: (DioException e, handler) {
            developer.log('❌ ERROR[${e.response?.statusCode}] => ${e.requestOptions.path}');
            developer.log('Error: ${e.message}');
            if (e.response?.data != null) {
              developer.log('Error response: ${e.response?.data}');
            }
            return handler.next(e);
          },
        ),
      );
      
      _isInitialized = true;
      developer.log('✅ API Service initialized successfully');
    } catch (e) {
      developer.log('❌ API Service initialization failed: $e');
      throw Exception('Failed to initialize API Service: $e');
    }
  }

  /// Parse cookies from Set-Cookie headers
  void _parseCookies(List<String> setCookieHeaders) {
    for (var header in setCookieHeaders) {
      final cookie = header.split(';')[0]; // Get only the cookie part
      final parts = cookie.split('=');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();
        _cookies[key] = value;
        
        // Store session_id separately for easy access
        if (key == 'session_id') {
          _sessionId = value;
          developer.log('🔐 Session ID stored: $_sessionId');
        }
      }
    }
  }

  void setSessionId(String? sessionId) {
    _sessionId = sessionId;
    if (sessionId != null) {
      _cookies['session_id'] = sessionId;
    } else {
      _cookies.remove('session_id');
    }
  }

  String? getSessionId() {
    return _sessionId;
  }

  void clearSession() {
    _sessionId = null;
    _cookies.clear();
    developer.log('🗑️ Session cleared');
  }

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
    if (!_isInitialized) {
      throw Exception('ApiService not initialized. Call initialize() first.');
    }

    try {
      final requestData = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': data,
        'id': DateTime.now().millisecondsSinceEpoch,
      };

      developer.log('🔄 Making POST request to: ${ApiConfig.baseUrl}$endpoint');
      developer.log('Request payload: ${jsonEncode(requestData)}');

      final response = await _dio.post(
        endpoint,
        data: jsonEncode(requestData),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return _handleSuccessResponse(response.data);
      } else {
        return ApiResponse(
          success: false,
          error: 'Server error: ${response.statusCode}',
          errorCode: 'HTTP_${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      developer.log('❌ DioException: ${e.message}');
      developer.log('Response: ${e.response?.data}');
      
      return _handleDioException(e);
    } catch (e) {
      developer.log('❌ Exception: $e');
      return ApiResponse(
        success: false,
        error: 'Unexpected error: ${e.toString()}',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  ApiResponse _handleSuccessResponse(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) {
      return ApiResponse(
        success: true,
        data: responseData,
      );
    }

    // Check for Odoo JSON-RPC error format
    if (responseData.containsKey('error')) {
      return _handleErrorResponse(responseData['error']);
    }
    
    // Check for result field (standard Odoo JSON-RPC)
    if (responseData.containsKey('result')) {
      final result = responseData['result'];
      
      // If result is a Map with success field, use it directly
      if (result is Map<String, dynamic> && result.containsKey('success')) {
        return ApiResponse.fromJson(result);
      }
      
      // If result is a Map without success field, wrap it
      if (result is Map<String, dynamic>) {
        return ApiResponse(
          success: true,
          data: result,
        );
      }
      
      // If result is a List or other type
      return ApiResponse(
        success: true,
        data: result,
      );
    }
    
    // Direct response format (no result wrapper)
    if (responseData.containsKey('success')) {
      return ApiResponse.fromJson(responseData);
    }
    
    // Fallback: treat entire response as data
    return ApiResponse(
      success: true,
      data: responseData,
    );
  }

  ApiResponse _handleErrorResponse(dynamic error) {
    String errorMessage = 'Unknown error';
    String? errorCode = 'API_ERROR';
    
    if (error is Map) {
      errorMessage = error['data']?['message'] ?? 
                   error['message'] ?? 
                   'Server error occurred';
      errorCode = error['code']?.toString() ?? errorCode;
    } else if (error is String) {
      errorMessage = error;
    }
    
    return ApiResponse(
      success: false,
      error: errorMessage,
      errorCode: errorCode,
    );
  }

  ApiResponse _handleDioException(DioException e) {
    if (e.response != null) {
      final responseData = e.response!.data;
      
      // Try to extract error message from Odoo response
      if (responseData is Map && responseData.containsKey('error')) {
        return _handleErrorResponse(responseData['error']);
      }
      
      // Try to extract from result
      if (responseData is Map && responseData.containsKey('result')) {
        final result = responseData['result'];
        if (result is Map && result.containsKey('error')) {
          return ApiResponse(
            success: false,
            error: result['error'],
            errorCode: result['error_code'],
          );
        }
      }
    }
    
    return ApiResponse(
      success: false,
      error: _getErrorMessage(e),
      errorCode: 'NETWORK_ERROR',
    );
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server returned an error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'Cannot connect to server. Please check:\n• Server URL is correct\n• Server is running\n• You are on the same network';
      case DioExceptionType.badCertificate:
        return 'SSL certificate error. Check your server configuration.';
      case DioExceptionType.unknown:
      default:
        if (e.message?.contains('SocketException') ?? false) {
          return 'Cannot connect to server. Please check your network connection.';
        }
        if (e.message?.contains('HandshakeException') ?? false) {
          return 'SSL handshake failed. Server may not support HTTPS.';
        }
        return 'Network error: ${e.message ?? "Unknown error"}';
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _sessionId != null && _sessionId!.isNotEmpty;
  }
}