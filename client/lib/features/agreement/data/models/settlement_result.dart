import 'package:equatable/equatable.dart';

/// DTO for settlement calculation result at end of consignment.
class SettlementResult extends Equatable {
  final int consignmentId;
  final String productName;
  final String shopName;
  final String consignorName;

  final int initialQuantity;
  final int soldQuantity;
  final int remainingQuantity;
  final double soldPercentage;

  final double totalSalesAmount;
  final double shopCommission;
  final double bonusAmount;
  final double totalShopEarning;
  final double consignorEarning;

  final String commissionBreakdown;
  final bool bonusApplied;

  const SettlementResult({
    required this.consignmentId,
    required this.productName,
    required this.shopName,
    required this.consignorName,
    required this.initialQuantity,
    required this.soldQuantity,
    required this.remainingQuantity,
    required this.soldPercentage,
    required this.totalSalesAmount,
    required this.shopCommission,
    required this.bonusAmount,
    required this.totalShopEarning,
    required this.consignorEarning,
    required this.commissionBreakdown,
    required this.bonusApplied,
  });

  factory SettlementResult.fromJson(Map<String, dynamic> json) {
    return SettlementResult(
      consignmentId: json['consignmentId'] as int,
      productName: json['productName'] as String,
      shopName: json['shopName'] as String,
      consignorName: json['consignorName'] as String,
      initialQuantity: json['initialQuantity'] as int,
      soldQuantity: json['soldQuantity'] as int,
      remainingQuantity: json['remainingQuantity'] as int,
      soldPercentage: (json['soldPercentage'] as num).toDouble(),
      totalSalesAmount: (json['totalSalesAmount'] as num).toDouble(),
      shopCommission: (json['shopCommission'] as num).toDouble(),
      bonusAmount: (json['bonusAmount'] as num?)?.toDouble() ?? 0.0,
      totalShopEarning: (json['totalShopEarning'] as num).toDouble(),
      consignorEarning: (json['consignorEarning'] as num).toDouble(),
      commissionBreakdown: json['commissionBreakdown'] as String,
      bonusApplied: json['bonusApplied'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    consignmentId,
    productName,
    shopName,
    consignorName,
    initialQuantity,
    soldQuantity,
    remainingQuantity,
    soldPercentage,
    totalSalesAmount,
    shopCommission,
    bonusAmount,
    totalShopEarning,
    consignorEarning,
    commissionBreakdown,
    bonusApplied,
  ];
}
