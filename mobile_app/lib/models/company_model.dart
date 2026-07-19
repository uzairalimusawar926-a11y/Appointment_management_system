class Company {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? website;
  final String? street;
  final String? street2;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;
  final String? logo;
  final String? currency;
  final String? currencySymbol;

  Company({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.website,
    this.street,
    this.street2,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.logo,
    this.currency,
    this.currencySymbol,
  });

  // Helper function to safely convert any value to String
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    return value.toString();
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: _safeString(json['name']) ?? 'Unknown Company',
      email: _safeString(json['email']),
      phone: _safeString(json['phone']),
      website: _safeString(json['website']),
      street: _safeString(json['street']),
      street2: _safeString(json['street2']),
      city: _safeString(json['city']),
      state: _safeString(json['state']),
      zip: _safeString(json['zip']),
      country: _safeString(json['country']),
      logo: _safeString(json['logo']),
      currency: _safeString(json['currency']),
      currencySymbol: _safeString(json['currency_symbol']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'website': website,
      'street': street,
      'street2': street2,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'logo': logo,
      'currency': currency,
      'currency_symbol': currencySymbol,
    };
  }

  String getFullAddress() {
    List<String> addressParts = [];
    if (street != null && street!.isNotEmpty) addressParts.add(street!);
    if (street2 != null && street2!.isNotEmpty) addressParts.add(street2!);
    if (city != null && city!.isNotEmpty) addressParts.add(city!);
    if (state != null && state!.isNotEmpty) addressParts.add(state!);
    if (zip != null && zip!.isNotEmpty) addressParts.add(zip!);
    if (country != null && country!.isNotEmpty) addressParts.add(country!);
    return addressParts.join(', ');
  }
}

class Order {
  final int id;
  final String name;
  final String? dateOrder;
  final String state;
  final String stateDisplay;
  final double amountTotal;
  final String? currencySymbol;

  Order({
    required this.id,
    required this.name,
    this.dateOrder,
    required this.state,
    required this.stateDisplay,
    required this.amountTotal,
    this.currencySymbol,
  });

  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    return value.toString();
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: _safeString(json['name']) ?? '',
      dateOrder: _safeString(json['date_order']),
      state: _safeString(json['state']) ?? '',
      stateDisplay: _safeString(json['state_display']) ?? '',
      amountTotal: (json['amount_total'] is num) 
          ? (json['amount_total'] as num).toDouble() 
          : double.tryParse(json['amount_total'].toString()) ?? 0.0,
      currencySymbol: _safeString(json['currency_symbol']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_order': dateOrder,
      'state': state,
      'state_display': stateDisplay,
      'amount_total': amountTotal,
      'currency_symbol': currencySymbol,
    };
  }
}

class Invoice {
  final int id;
  final String name;
  final String? invoiceDate;
  final String state;
  final String stateDisplay;
  final double amountTotal;
  final double amountResidual;
  final String? currencySymbol;
  final String? paymentState;

  Invoice({
    required this.id,
    required this.name,
    this.invoiceDate,
    required this.state,
    required this.stateDisplay,
    required this.amountTotal,
    required this.amountResidual,
    this.currencySymbol,
    this.paymentState,
  });

  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    return value.toString();
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: _safeString(json['name']) ?? '',
      invoiceDate: _safeString(json['invoice_date']),
      state: _safeString(json['state']) ?? '',
      stateDisplay: _safeString(json['state_display']) ?? '',
      amountTotal: (json['amount_total'] is num) 
          ? (json['amount_total'] as num).toDouble() 
          : double.tryParse(json['amount_total'].toString()) ?? 0.0,
      amountResidual: (json['amount_residual'] is num) 
          ? (json['amount_residual'] as num).toDouble() 
          : double.tryParse(json['amount_residual'].toString()) ?? 0.0,
      currencySymbol: _safeString(json['currency_symbol']),
      paymentState: _safeString(json['payment_state']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'invoice_date': invoiceDate,
      'state': state,
      'state_display': stateDisplay,
      'amount_total': amountTotal,
      'amount_residual': amountResidual,
      'currency_symbol': currencySymbol,
      'payment_state': paymentState,
    };
  }
}

class UserProfile {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? mobile;
  final String? street;
  final String? street2;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.mobile,
    this.street,
    this.street2,
    this.city,
    this.state,
    this.zip,
    this.country,
  });

  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    return value.toString();
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: _safeString(json['name']) ?? '',
      email: _safeString(json['email']),
      phone: _safeString(json['phone']),
      mobile: _safeString(json['mobile']),
      street: _safeString(json['street']),
      street2: _safeString(json['street2']),
      city: _safeString(json['city']),
      state: _safeString(json['state']),
      zip: _safeString(json['zip']),
      country: _safeString(json['country']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'street': street,
      'street2': street2,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
    };
  }
}