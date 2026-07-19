import 'package:flutter/foundation.dart';
import '../models/company_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';
import 'dart:developer' as developer;

class CompanyController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Company? _company;
  bool _isLoading = false;
  String? _errorMessage;

  Company? get company => _company;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> fetchCompanySettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      developer.log('🏢 Fetching company settings...');
      
      // Check if API service is initialized
      if (!_apiService.isInitialized) {
        developer.log('⚠️ API Service not initialized, initializing now...');
        _apiService.initialize();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final response = await _apiService.post(ApiConfig.companySettingsEndpoint, {});

      developer.log('Company settings response success: ${response.success}');
      developer.log('Company settings response data: ${response.data}');
      developer.log('Company settings response error: ${response.error}');

      if (response.success && response.data != null) {
        try {
          // Handle if data is a Map
          if (response.data is Map<String, dynamic>) {
            _company = Company.fromJson(response.data);
          } else {
            developer.log('❌ Unexpected data type: ${response.data.runtimeType}');
            _errorMessage = 'Unexpected response format from server';
            _isLoading = false;
            notifyListeners();
            return false;
          }
          
          // Cache company logo
          if (_company?.logo != null) {
            try {
              await _storageService.saveCompanyLogo(_company!.logo!);
            } catch (e) {
              developer.log('⚠️ Failed to cache logo: $e');
            }
          }
          
          _isLoading = false;
          notifyListeners();
          developer.log('✅ Company settings loaded successfully');
          return true;
        } catch (e) {
          developer.log('❌ Error parsing company data: $e');
          _errorMessage = 'Failed to parse company data: ${e.toString()}';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = response.error ?? 'Failed to load company settings';
        developer.log('❌ Failed to load company settings: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error loading company settings: ${e.toString()}';
      developer.log('❌ Exception in fetchCompanySettings: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String? getCachedLogo() {
    return _storageService.getCompanyLogo();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class PortalController with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  List<Invoice> _invoices = [];
  UserProfile? _profile;

  bool _isOrdersLoading = false;
  bool _isInvoicesLoading = false;
  bool _isProfileLoading = false;
  bool _isUpdatingProfile = false;

  String? _errorMessage;

  // Pagination
  int _ordersOffset = 0;
  int _invoicesOffset = 0;
  int _ordersLimit = 20;
  int _invoicesLimit = 20;
  int _totalOrders = 0;
  int _totalInvoices = 0;

  // Getters
  List<Order> get orders => _orders;
  List<Invoice> get invoices => _invoices;
  UserProfile? get profile => _profile;
  bool get isOrdersLoading => _isOrdersLoading;
  bool get isInvoicesLoading => _isInvoicesLoading;
  bool get isProfileLoading => _isProfileLoading;
  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get errorMessage => _errorMessage;
  int get totalOrders => _totalOrders;
  int get totalInvoices => _totalInvoices;
  bool get hasMoreOrders => _orders.length < _totalOrders;
  bool get hasMoreInvoices => _invoices.length < _totalInvoices;

  // ==================== Fetch Orders ====================

  Future<bool> fetchOrders({bool loadMore = false}) async {
    if (loadMore && !hasMoreOrders) return false;

    _isOrdersLoading = true;
    _errorMessage = null;
    
    if (!loadMore) {
      _ordersOffset = 0;
      _orders = [];
    }
    
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConfig.portalOrdersEndpoint,
        {
          'limit': _ordersLimit,
          'offset': _ordersOffset,
        },
      );

      if (response.success && response.data != null) {
        final ordersData = response.data['orders'] as List;
        final newOrders = ordersData.map((json) => Order.fromJson(json)).toList();
        
        if (loadMore) {
          _orders.addAll(newOrders);
        } else {
          _orders = newOrders;
        }
        
        _totalOrders = response.data['total_count'] ?? 0;
        _ordersOffset += newOrders.length;
        
        _isOrdersLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error ?? 'Failed to load orders';
        _isOrdersLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error loading orders: ${e.toString()}';
      _isOrdersLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== Fetch Invoices ====================

  Future<bool> fetchInvoices({bool loadMore = false}) async {
    if (loadMore && !hasMoreInvoices) return false;

    _isInvoicesLoading = true;
    _errorMessage = null;
    
    if (!loadMore) {
      _invoicesOffset = 0;
      _invoices = [];
    }
    
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConfig.portalInvoicesEndpoint,
        {
          'limit': _invoicesLimit,
          'offset': _invoicesOffset,
        },
      );

      if (response.success && response.data != null) {
        final invoicesData = response.data['invoices'] as List;
        final newInvoices = invoicesData.map((json) => Invoice.fromJson(json)).toList();
        
        if (loadMore) {
          _invoices.addAll(newInvoices);
        } else {
          _invoices = newInvoices;
        }
        
        _totalInvoices = response.data['total_count'] ?? 0;
        _invoicesOffset += newInvoices.length;
        
        _isInvoicesLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error ?? 'Failed to load invoices';
        _isInvoicesLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error loading invoices: ${e.toString()}';
      _isInvoicesLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== Fetch Profile ====================

  Future<bool> fetchProfile() async {
    _isProfileLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(ApiConfig.portalProfileEndpoint, {});

      if (response.success && response.data != null) {
        _profile = UserProfile.fromJson(response.data);
        _isProfileLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error ?? 'Failed to load profile';
        _isProfileLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error loading profile: ${e.toString()}';
      _isProfileLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== Update Profile ====================

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _isUpdatingProfile = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConfig.updateProfileEndpoint,
        updates,
      );

      _isUpdatingProfile = false;

      if (response.success) {
        // Refresh profile data
        await fetchProfile();
        return true;
      } else {
        _errorMessage = response.error ?? 'Failed to update profile';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating profile: ${e.toString()}';
      _isUpdatingProfile = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}