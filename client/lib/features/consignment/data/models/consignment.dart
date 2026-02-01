import 'package:equatable/equatable.dart';

import '../../../products/data/models/product.dart';

/// Consignment status enum matching backend ConsignmentStatus.
enum ConsignmentStatus {
  active,
  completed,
  expired,
  returned;

  String get displayName => switch (this) {
    ConsignmentStatus.active => 'Aktif',
    ConsignmentStatus.completed => 'Selesai',
    ConsignmentStatus.expired => 'Kadaluarsa',
    ConsignmentStatus.returned => 'Dikembalikan',
  };

  static ConsignmentStatus fromString(String value) {
    return ConsignmentStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ConsignmentStatus.active,
    );
  }
}

/// Shop model (simplified for consignment context).
class Shop extends Equatable {
  final int id;
  final String name;
  final String? address;
  final String? phone;

  const Shop({required this.id, required this.name, this.address, this.phone});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, address, phone];
}

/// Consignment model matching backend Consignment entity.
class Consignment extends Equatable {
  final int id;
  final Product product;
  final Shop shop;
  final int initialQuantity;
  final int currentQuantity;
  final double sellingPrice;
  final double commissionPercent;
  final DateTime? consignmentDate;
  final DateTime? expiryDate;
  final ConsignmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Consignment({
    required this.id,
    required this.product,
    required this.shop,
    required this.initialQuantity,
    required this.currentQuantity,
    required this.sellingPrice,
    required this.commissionPercent,
    this.consignmentDate,
    this.expiryDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Quantity that has been sold.
  int get soldQuantity => initialQuantity - currentQuantity;

  /// Check if consignment is expired.
  bool get isExpired =>
      expiryDate != null && DateTime.now().isAfter(expiryDate!);

  /// Check if consignment is expiring within given days.
  bool isExpiringWithin(int days) {
    if (expiryDate == null) return false;
    return DateTime.now().add(Duration(days: days)).isAfter(expiryDate!);
  }

  factory Consignment.fromJson(Map<String, dynamic> json) {
    return Consignment(
      id: json['id'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      shop: Shop.fromJson(json['shop'] as Map<String, dynamic>),
      initialQuantity: json['initialQuantity'] as int,
      currentQuantity: json['currentQuantity'] as int,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      commissionPercent: (json['commissionPercent'] as num).toDouble(),
      consignmentDate: json['consignmentDate'] != null
          ? DateTime.parse(json['consignmentDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      status: ConsignmentStatus.fromString(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    product,
    shop,
    initialQuantity,
    currentQuantity,
    sellingPrice,
    commissionPercent,
    consignmentDate,
    expiryDate,
    status,
    notes,
    createdAt,
    updatedAt,
  ];
}
