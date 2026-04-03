import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? licenseNumber;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.licenseNumber,
    this.phone,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      licenseNumber: json['licenseNumber']?.toString(),
      phone: json['phone']?.toString(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.tryParse(json['lastLogin'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'licenseNumber': licenseNumber,
      'phone': phone,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? licenseNumber,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.email == email;
  }

  @override
  int get hashCode => email.hashCode;

  @override
  String toString() {
    return 'User(email: $email, name: $name, role: $role)';
  }

  // Helper methods
  bool get isAdmin => role == 'Admin';
  bool get isMR => role == 'MR';
  bool get isStockist => role == 'Stockist';
  bool get isRetailer => role == 'Retailer';
  bool get isDoctor => role == 'Doctor';
  bool get isAccountant => role == 'Accountant';

  String get displayName {
    if (name.isNotEmpty) return name;
    final emailName = email.split('@')[0];
    return emailName.isNotEmpty ? emailName : 'User';
  }

  String get initials {
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name.substring(0, 2).toUpperCase();
    }
    
    final emailName = email.split('@')[0];
    return emailName.length >= 2 
        ? emailName.substring(0, 2).toUpperCase()
        : emailName.toUpperCase();
  }

  String get roleDisplayName {
    switch (role) {
      case 'Admin':
        return 'System Administrator';
      case 'MR':
        return 'Medical Representative';
      case 'Stockist':
        return 'Stockist/Distributor';
      case 'Retailer':
        return 'Retailer/Pharmacy';
      case 'Doctor':
        return 'Medical Doctor';
      case 'Accountant':
        return 'Accountant';
      default:
        return 'User';
    }
  }

  String get roleIcon {
    switch (role) {
      case 'Admin':
        return 'admin_panel_settings';
      case 'MR':
        return 'directions_walk';
      case 'Stockist':
        return 'inventory';
      case 'Retailer':
        return 'store';
      case 'Doctor':
        return 'local_hospital';
      case 'Accountant':
        return 'account_balance';
      default:
        return 'person';
    }
  }
}
