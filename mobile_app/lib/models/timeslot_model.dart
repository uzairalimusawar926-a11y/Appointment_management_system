class TimeSlot {
  final int id;
  final String name;
  final String day;
  final bool isBooked;
  final List<int> userIds;

  TimeSlot({
    required this.id,
    required this.name,
    required this.day,
    required this.isBooked,
    required this.userIds,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      day: json['day'] ?? '',
      isBooked: json['is_booked'] ?? false,
      userIds: List<int>.from(json['user_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'day': day,
      'is_booked': isBooked,
      'user_ids': userIds,
    };
  }
}

class Booking {
  final int id;
  final String name;
  final String? bookingDate;
  final String timeSlots;
  final String? appointmentName;
  final String? appointmentLocation;
  final double fees;
  final String state;
  final String stateDisplay;
  final String? start;
  final String? stop;

  Booking({
    required this.id,
    required this.name,
    this.bookingDate,
    required this.timeSlots,
    this.appointmentName,
    this.appointmentLocation,
    required this.fees,
    required this.state,
    required this.stateDisplay,
    this.start,
    this.stop,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      bookingDate: json['booking_date'],
      timeSlots: json['time_slots'] ?? '',
      appointmentName: json['appointment_name'],
      appointmentLocation: json['appointment_location'],
      fees: (json['fees'] ?? 0).toDouble(),
      state: json['state'] ?? 'draft',
      stateDisplay: json['state_display'] ?? 'Draft',
      start: json['start'],
      stop: json['stop'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'booking_date': bookingDate,
      'time_slots': timeSlots,
      'appointment_name': appointmentName,
      'appointment_location': appointmentLocation,
      'fees': fees,
      'state': state,
      'state_display': stateDisplay,
      'start': start,
      'stop': stop,
    };
  }
}
