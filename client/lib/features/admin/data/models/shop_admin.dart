import 'package:equatable/equatable.dart';

/// Admin view of shop data with statistics
class ShopAdmin extends Equatable {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? description;
  final String ownerName;
  final String ownerEmail;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;

  // Statistics
  final int totalProducts;
  final int totalConsignments;
  final int totalSales;
  final double totalRevenue;
  final double? averageRating;

  const ShopAdmin({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.description,
    required this.ownerName,
    required this.ownerEmail,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.totalProducts,
    required this.totalConsignments,
    required this.totalSales,
    required this.totalRevenue,
    this.averageRating,
  });

  factory ShopAdmin.fromJson(Map<String, dynamic> json) {
    return ShopAdmin(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      ownerName: json['ownerName'] as String,
      ownerEmail: json['ownerEmail'] as String,
      isActive: json['isActive'] as bool,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
      'address': address,
      'phone': phone,
      'description': description,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'totalProducts': totalProducts,
      'totalConsignments': totalConsignments,
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'averageRating': averageRating,
    };
  }

  @override
  List<Object?> get props => [id, name];
}
