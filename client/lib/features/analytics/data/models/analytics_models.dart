import 'package:equatable/equatable.dart';

/// Daily sales/earnings trend data point.
class TrendData extends Equatable {
  final DateTime date;
  final int salesCount;
  final int itemsSold;
  final double totalAmount;
  final double earnings;

  const TrendData({
    required this.date,
    required this.salesCount,
    required this.itemsSold,
    required this.totalAmount,
    required this.earnings,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      date: DateTime.parse(json['date'] as String),
      salesCount: json['salesCount'] as int,
      itemsSold: json['itemsSold'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      earnings: (json['earnings'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    date,
    salesCount,
    itemsSold,
    totalAmount,
    earnings,
  ];
}

/// Top performing product.
class TopProduct extends Equatable {
  final int productId;
  final String productName;
  final String? category;
  final int totalSold;
  final double totalRevenue;
  final double totalEarnings;

  const TopProduct({
    required this.productId,
    required this.productName,
    this.category,
    required this.totalSold,
    required this.totalRevenue,
    required this.totalEarnings,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      category: json['category'] as String?,
      totalSold: json['totalSold'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    category,
    totalSold,
    totalRevenue,
    totalEarnings,
  ];
}

/// Earnings breakdown by product.
class EarningsBreakdown extends Equatable {
  final int productId;
  final String productName;
  final String? category;
  final double earnings;
  final double percentage;

  const EarningsBreakdown({
    required this.productId,
    required this.productName,
    this.category,
    required this.earnings,
    required this.percentage,
  });

  factory EarningsBreakdown.fromJson(Map<String, dynamic> json) {
    return EarningsBreakdown(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      category: json['category'] as String?,
      earnings: (json['earnings'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    category,
    earnings,
    percentage,
  ];
}
