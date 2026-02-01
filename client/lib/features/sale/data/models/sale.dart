import 'package:equatable/equatable.dart';

import '../../../consignment/data/models/consignment.dart';

/// Sale model matching backend Sale entity.
class Sale extends Equatable {
  final int id;
  final Consignment consignment;
  final int quantitySold;
  final double totalAmount;
  final double shopCommission;
  final double consignorEarning;
  final DateTime soldAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Sale({
    required this.id,
    required this.consignment,
    required this.quantitySold,
    required this.totalAmount,
    required this.shopCommission,
    required this.consignorEarning,
    required this.soldAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as int,
      consignment: Consignment.fromJson(
        json['consignment'] as Map<String, dynamic>,
      ),
      quantitySold: json['quantitySold'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      shopCommission: (json['shopCommission'] as num).toDouble(),
      consignorEarning: (json['consignorEarning'] as num).toDouble(),
      soldAt: DateTime.parse(json['soldAt'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    consignment,
    quantitySold,
    totalAmount,
    shopCommission,
    consignorEarning,
    soldAt,
    notes,
    createdAt,
    updatedAt,
  ];
}

/// Sales summary model.
class SalesSummary extends Equatable {
  final double totalEarnings;
  final int totalSales;
  final int totalItemsSold;
  final DateTime startDate;
  final DateTime endDate;

  const SalesSummary({
    required this.totalEarnings,
    required this.totalSales,
    required this.totalItemsSold,
    required this.startDate,
    required this.endDate,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      totalSales: json['totalSales'] as int? ?? 0,
      totalItemsSold: json['totalItemsSold'] as int? ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  @override
  List<Object?> get props => [
    totalEarnings,
    totalSales,
    totalItemsSold,
    startDate,
    endDate,
  ];
}
