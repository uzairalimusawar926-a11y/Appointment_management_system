import 'package:flutter/foundation.dart';

class ApiConfig {
  // Default base URL (change this to your Odoo server's URL)
  static String _baseUrl = 'http://192.168.0.113:8069';

  // Odoo database name - change this if your database name is different
  static const String database = 'appointment_app_3';

  // Timeouts (milliseconds)
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Common headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Getter for base URL
  static String get baseUrl => _baseUrl;

  // Setter for base URL
  static void setBaseUrl(String url) {
    // Remove trailing slash if present
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;

    if (kDebugMode) {
      print('Base URL set to: $_baseUrl');
    }
  }

  // ==================== ODOO BUILT-IN ENDPOINTS ====================

  // Authentication endpoints (Odoo built-in)
  static const String loginEndpoint = '/web/session/authenticate';
  static const String logoutEndpoint = '/web/session/destroy';
  static const String checkAuthEndpoint = '/web/session/get_session_info';
  static const String sessionCheckEndpoint = '/web/session/check';

  // ==================== CUSTOM API ENDPOINTS ====================

  // Custom auth endpoints
  static const String customLoginEndpoint = '/api/v1/auth/login';
  static const String customLogoutEndpoint = '/api/v1/auth/logout';
  static const String customCheckAuthEndpoint = '/api/v1/auth/check';
  static const String signupEndpoint = '/api/v1/auth/signup';

  // Company endpoint - Odoo mein add karni hogi
  static const String companySettingsEndpoint = '/api/v1/company/settings';

  // Appointment endpoints
  static const String appointmentsListEndpoint = '/api/v1/appointments/list';
  static const String appointmentDetailEndpoint = '/api/v1/appointments/detail';
  static const String availableSlotsEndpoint = '/api/v1/appointments/available-slots';
  static const String bookAppointmentEndpoint = '/api/v1/appointments/book';
  static const String myBookingsEndpoint = '/api/v1/appointments/my-bookings';
  static const String cancelAppointmentEndpoint = '/api/v1/appointments/cancel';

  // Portal endpoints
  static const String portalOrdersEndpoint = '/api/v1/portal/orders';
  static const String portalInvoicesEndpoint = '/api/v1/portal/invoices';
  static const String portalProfileEndpoint = '/api/v1/portal/profile';
  static const String updateProfileEndpoint = '/api/v1/portal/update-profile';

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$_baseUrl$endpoint';
  }

  // Helper method to log API calls in debug mode
  static void logApiCall(String endpoint, Map<String, dynamic>? data) {
    if (kDebugMode) {
      print('API Call: $endpoint');
      if (data != null) {
        print('Data: $data');
      }
    }
  }

  // Check if running in production
  static bool get isProduction => kReleaseMode;

  // Get environment name
  static String get environment {
    if (kReleaseMode) return 'Production';
    if (kProfileMode) return 'Profile';
    return 'Development';
  }

  // Reset to default URL (useful for testing)
  static void resetToDefault() {
    _baseUrl = 'http://192.168.100.31:8069';
    if (kDebugMode) {
      print('Base URL reset to default: $_baseUrl');
    }
  }

  // Validate URL format
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}