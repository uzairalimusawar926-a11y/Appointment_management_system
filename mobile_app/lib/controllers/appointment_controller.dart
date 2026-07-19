import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AppointmentController with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Appointment> _appointments = [];
  Appointment? _selectedAppointment;
  List<TimeSlot> _availableSlots = [];
  TimeSlot? _selectedSlot;
  DateTime? _selectedDate;
  int? _selectedUserId;
  List<Booking> _myBookings = [];

  bool _isLoading = false;
  bool _isSlotsLoading = false;
  bool _isBookingLoading = false;
  String? _errorMessage;

  // Getters
  List<Appointment> get appointments => _appointments;
  Appointment? get selectedAppointment => _selectedAppointment;
  List<TimeSlot> get availableSlots => _availableSlots;
  TimeSlot? get selectedSlot => _selectedSlot;
  DateTime? get selectedDate => _selectedDate;
  int? get selectedUserId => _selectedUserId;
  List<Booking> get myBookings => _myBookings;
  bool get isLoading => _isLoading;
  bool get isSlotsLoading => _isSlotsLoading;
  bool get isBookingLoading => _isBookingLoading;
  String? get errorMessage => _errorMessage;

  // ==================== Fetch Appointments ====================

  Future<bool> fetchAppointments() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(ApiConfig.appointmentsListEndpoint, {});

      if (response.success && response.data != null) {
        _appointments = (response.data as List)
            .map((json) => Appointment.fromJson(json))
            .toList();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to load appointments');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error loading appointments: $e');
      _setError('Error loading appointments: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ==================== Get Appointment Detail ====================

  Future<bool> fetchAppointmentDetail(int appointmentId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        ApiConfig.appointmentDetailEndpoint,
        {'appointment_id': appointmentId},
      );

      if (response.success && response.data != null) {
        _selectedAppointment = Appointment.fromJson(response.data);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to load appointment details');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error loading appointment details: $e');
      _setError('Error loading appointment details: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ==================== Select Appointment ====================

  void selectAppointment(Appointment appointment) {
    _selectedAppointment = appointment;
    _availableSlots = [];
    _selectedSlot = null;
    _selectedDate = null;
    _selectedUserId = null;
    notifyListeners();
  }

  // ==================== Select User ====================

  void selectUser(int? userId) {
    _selectedUserId = userId;
    // Clear slots when user changes
    if (_selectedDate != null) {
      fetchAvailableSlots(_selectedDate!);
    }
    notifyListeners();
  }

  // ==================== Select Date ====================

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedSlot = null;
    fetchAvailableSlots(date);
  }

  // ==================== Fetch Available Slots ====================

  Future<bool> fetchAvailableSlots(DateTime date) async {
    if (_selectedAppointment == null) return false;

    _isSlotsLoading = true;
    _clearError();
    notifyListeners();

    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final params = {
        'appointment_id': _selectedAppointment!.id,
        'selected_date': dateString,
      };
      
      if (_selectedUserId != null) {
        params['user_id'] = _selectedUserId!;
      }

      final response = await _apiService.post(
        ApiConfig.availableSlotsEndpoint,
        params,
      );

      if (response.success && response.data != null) {
        _availableSlots = (response.data as List)
            .map((json) => TimeSlot.fromJson(json))
            .toList();
        _isSlotsLoading = false;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to load time slots');
        _isSlotsLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error loading time slots: $e');
      _setError('Error loading time slots: ${e.toString()}');
      _isSlotsLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== Select Slot ====================

  void selectSlot(TimeSlot slot) {
    if (!slot.isBooked) {
      _selectedSlot = slot;
      notifyListeners();
    }
  }

  // ==================== Book Appointment ====================

  Future<Map<String, dynamic>?> bookAppointment({
    required String contactName,
    required String email,
    required String mobile,
    String? description,
  }) async {
    if (_selectedAppointment == null ||
        _selectedSlot == null ||
        _selectedDate == null) {
      _setError('Please select appointment, date and time slot');
      return null;
    }

    _isBookingLoading = true;
    _clearError();
    notifyListeners();

    try {
      final dateString = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      
      final params = {
        'appointment_id': _selectedAppointment!.id,
        'slot_id': _selectedSlot!.id,
        'selected_date': dateString,
        'contact_name': contactName,
        'email': email,
        'mobile': mobile,
        'description': description ?? '',
      };
      
      if (_selectedUserId != null) {
        params['user_id'] = _selectedUserId!;
      }

      final response = await _apiService.post(
        ApiConfig.bookAppointmentEndpoint,
        params,
      );

      _isBookingLoading = false;

     if (response.success) {
             // Reset selections after successful booking
             _selectedSlot = null;
             _selectedDate = null;
             _selectedUserId = null;
             // Refresh bookings list immediately
             await fetchMyBookings();
             notifyListeners();
             return response.data;
      } else {
        _setError(response.error ?? 'Failed to book appointment');
        notifyListeners();
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error booking appointment: $e');
      _setError('Error booking appointment: ${e.toString()}');
      _isBookingLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ==================== Fetch My Bookings ====================

  Future<bool> fetchMyBookings() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(ApiConfig.myBookingsEndpoint, {});

      if (response.success && response.data != null) {
        _myBookings = (response.data as List)
            .map((json) => Booking.fromJson(json))
            .toList();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to load bookings');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error loading bookings: $e');
      _setError('Error loading bookings: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ==================== Cancel Appointment ====================

  Future<bool> cancelAppointment(int eventId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        ApiConfig.cancelAppointmentEndpoint,
        {'event_id': eventId},
      );

      _setLoading(false);

      if (response.success) {
        // Refresh bookings after cancellation
        await fetchMyBookings();
        return true;
      } else {
        _setError(response.error ?? 'Failed to cancel appointment');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error cancelling appointment: $e');
      _setError('Error cancelling appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ==================== Reset Selections ====================

  void resetBookingFlow() {
    _selectedAppointment = null;
    _selectedSlot = null;
    _selectedDate = null;
    _selectedUserId = null;
    _availableSlots = [];
    notifyListeners();
  }

  // ==================== Helper Methods ====================

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
}