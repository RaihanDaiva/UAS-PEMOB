class User {
  final int id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String role;
  final String registrationStatus;
  final String? address;
  final bool isActive;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    required this.registrationStatus,
    this.address,
    required this.isActive,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      role: json['role'],
      registrationStatus: json['registration_status'],
      address: json['address'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'registration_status': registrationStatus,
      'address': address,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isClient => role == 'client';
  bool get isApproved => registrationStatus == 'approved';
  bool get isPending => registrationStatus == 'pending';
  bool get isRejected => registrationStatus == 'rejected';
}