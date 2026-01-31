import 'package:equatable/equatable.dart';

/// ConsignmentStatus enum matching backend.
enum ConsignmentStatus {
  active('ACTIVE'),
  completed('COMPLETED'),
  returned('RETURNED'),
  expired('EXPIRED');

  final String value;
  const ConsignmentStatus(this.value);

  static ConsignmentStatus fromString(String value) {
    return ConsignmentStatus.values.firstWhere(
      (s) => s.value == value.toUpperCase(),
      orElse: () => ConsignmentStatus.active,
    );
  }
}

/// Consignment model matching backend Consignment entity.
class Consignment extends Equatable {
  final int id;
  final ConsignmentProduct product;
  final ConsignmentShop shop;
  final int initialQuantity;
  final int currentQuantity;
  final double sellingPrice;
  final double commissionPercent;
  final DateTime? consignmentDate;
  final DateTime? expiryDate;
  final ConsignmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

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
    this.updatedAt,
  });

  factory Consignment.fromJson(Map<String, dynamic> json) {
    return Consignment(
      id: json['id'] as int,
      product: ConsignmentProduct.fromJson(
        json['product'] as Map<String, dynamic>,
      ),
      shop: ConsignmentShop.fromJson(json['shop'] as Map<String, dynamic>),
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
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Check if consignment is expiring within given days.
  bool isExpiringWithin(int days) {
    if (expiryDate == null) return false;
    return DateTime.now().add(Duration(days: days)).isAfter(expiryDate!);
  }

  /// Check if quantity is low (below threshold).
  bool isLowStock({int threshold = 5}) {
    return currentQuantity <= threshold;
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

/// Nested product summary within Consignment.
class ConsignmentProduct extends Equatable {
  final int id;
  final String name;
  final String? category;
  final double basePrice;
  final String? imageUrl;

  const ConsignmentProduct({
    required this.id,
    required this.name,
    this.category,
    required this.basePrice,
    this.imageUrl,
  });

  factory ConsignmentProduct.fromJson(Map<String, dynamic> json) {
    return ConsignmentProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, category, basePrice, imageUrl];
}

/// Nested shop summary within Consignment.
class ConsignmentShop extends Equatable {
  final int id;
  final String name;
  final String? address;

  const ConsignmentShop({required this.id, required this.name, this.address});

  factory ConsignmentShop.fromJson(Map<String, dynamic> json) {
    return ConsignmentShop(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, address];
}
