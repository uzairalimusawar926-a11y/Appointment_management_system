class User {
  final int id;
  final String name;
  final String email;
  final String login;
  final int? partnerId;
  final int? companyId;
  final String? companyName;
  final String timezone;
  final String? sessionId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.login,
    this.partnerId,
    this.companyId,
    this.companyName,
    required this.timezone,
    this.sessionId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      login: json['login'] as String? ?? json['email'] as String,
      partnerId: json['partner_id'] as int?,
      companyId: json['company_id'] as int?,
      companyName: json['company_name'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      sessionId: json['session_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'login': login,
      'partner_id': partnerId,
      'company_id': companyId,
      'company_name': companyName,
      'timezone': timezone,
      'session_id': sessionId,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? login,
    int? partnerId,
    int? companyId,
    String? companyName,
    String? timezone,
    String? sessionId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      login: login ?? this.login,
      partnerId: partnerId ?? this.partnerId,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      timezone: timezone ?? this.timezone,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, login: $login)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is User &&
      other.id == id &&
      other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode;
  }
}