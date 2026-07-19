// lib/models/appointment_model.dart

class Appointment {
  final int id;
  final String name;
  final String? description;
  final String? location;
  final double fees;
  final String? appointmentType;
  final String? appointmentTypeDisplay;
  final int slotDuration;
  final String? image;
  final List<int> userIds;
  final List<AppointmentUser> users;

  Appointment({
    required this.id,
    required this.name,
    this.description,
    this.location,
    required this.fees,
    this.appointmentType,
    this.appointmentTypeDisplay,
    required this.slotDuration,
    this.image,
    required this.userIds,
    required this.users,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description']?.toString(),
      location: json['location']?.toString(),
      fees: (json['fees'] ?? 0).toDouble(),
      appointmentType: json['appointment_type']?.toString(),
      appointmentTypeDisplay: json['appointment_type_display']?.toString(),
      slotDuration: json['slot_duration'] ?? 60,
      image: json['image']?.toString(),
      userIds: List<int>.from(json['user_ids'] ?? []),
      users: (json['users'] as List<dynamic>?)
              ?.map((u) => AppointmentUser.fromJson(u))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'fees': fees,
      'appointment_type': appointmentType,
      'appointment_type_display': appointmentTypeDisplay,
      'slot_duration': slotDuration,
      'image': image,
      'user_ids': userIds,
      'users': users.map((u) => u.toJson()).toList(),
    };
  }
}

class AppointmentUser {
  final int id;
  final String name;
  final String? timezone;

  AppointmentUser({
    required this.id,
    required this.name,
    this.timezone,
  });

  factory AppointmentUser.fromJson(Map<String, dynamic> json) {
    return AppointmentUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      timezone: json['timezone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'timezone': timezone,
    };
  }
}

class TimeSlot {
  final int id;
  final String name;
  final String? day;
  final bool isBooked;
  final List<int> userIds;

  TimeSlot({
    required this.id,
    required this.name,
    this.day,
    required this.isBooked,
    required this.userIds,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      day: json['day']?.toString(),
      isBooked: json['is_booked'] == true,
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
  final String? timeSlots;
  final String? appointmentName;
  final String? appointmentLocation;
  final double? fees;
  final String state;
  final String stateDisplay;
  final String? start;
  final String? stop;

  Booking({
    required this.id,
    required this.name,
    this.bookingDate,
    this.timeSlots,
    this.appointmentName,
    this.appointmentLocation,
    this.fees,
    required this.state,
    required this.stateDisplay,
    this.start,
    this.stop,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      bookingDate: json['booking_date']?.toString(),
      timeSlots: json['time_slots']?.toString(),
      appointmentName: json['appointment_name']?.toString(),
      appointmentLocation: json['appointment_location']?.toString(),
      fees: json['fees'] != null ? (json['fees'] as num).toDouble() : null,
      state: json['state'] ?? 'draft',
      stateDisplay: json['state_display'] ?? 'Draft',
      start: json['start']?.toString(),
      stop: json['stop']?.toString(),
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

    // Convenience getters
    bool get isDraft => state == 'draft';
    bool get isConfirmed => state == 'confirmed';
    bool get isCancelled => state == 'cancelled';
    bool get isDone => state == 'done';
  }