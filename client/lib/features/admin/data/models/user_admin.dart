import 'package:equatable/equatable.dart';

/// Admin view of user data with statistics
class UserAdmin extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Statistics
  final int totalProducts;
  final int totalConsignments;
  final int totalSales;
  final double totalRevenue;
  final double? averageRating;

  const UserAdmin({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    required this.createdAt,
    this.lastLoginAt,
    required this.totalProducts,
    required this.totalConsignments,
    required this.totalSales,
    required this.totalRevenue,
    this.averageRating,
  });

  factory UserAdmin.fromJson(Map<String, dynamic> json) {
    return UserAdmin(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      totalConsignments: (json['totalConsignments'] as num?)?.toInt() ?? 0,
      totalSales: (json['totalSales'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'totalProducts': totalProducts,
      'totalConsignments': totalConsignments,
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'averageRating': averageRating,
    };
  }

  @override
  List<Object?> get props => [id, email];
}
