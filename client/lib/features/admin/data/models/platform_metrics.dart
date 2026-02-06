import 'package:equatable/equatable.dart';

/// Platform-wide metrics for admin dashboard
class PlatformMetrics extends Equatable {
  // User metrics
  final int totalUsers;
  final int totalShopOwners;
  final int totalConsignors;
  final int activeUsersLast7Days;
  final int newUsersThisMonth;

  // Shop metrics
  final int totalShops;
  final int activeShops;
  final int pendingVerifications;

  // Product metrics
  final int totalProducts;
  final int activeProducts;

  // Consignment metrics
  final int totalConsignments;
  final int activeConsignments;
  final int expiringConsignments;

  // Financial metrics
  final double totalGMV;
  final double monthlyGMV;
  final double platformRevenue;
  final int totalTransactions;

  // Growth metrics
  final double userGrowthRate;
  final double revenueGrowthRate;

  const PlatformMetrics({
    required this.totalUsers,
    required this.totalShopOwners,
    required this.totalConsignors,
    required this.activeUsersLast7Days,
    required this.newUsersThisMonth,
    required this.totalShops,
    required this.activeShops,
    required this.pendingVerifications,
    required this.totalProducts,
    required this.activeProducts,
    required this.totalConsignments,
    required this.activeConsignments,
    required this.expiringConsignments,
    required this.totalGMV,
    required this.monthlyGMV,
    required this.platformRevenue,
    required this.totalTransactions,
    required this.userGrowthRate,
    required this.revenueGrowthRate,
  });

  factory PlatformMetrics.fromJson(Map<String, dynamic> json) {
    return PlatformMetrics(
      totalUsers: (json['totalUsers'] as num).toInt(),
      totalShopOwners: (json['totalShopOwners'] as num).toInt(),
      totalConsignors: (json['totalConsignors'] as num).toInt(),
      activeUsersLast7Days: (json['activeUsersLast7Days'] as num).toInt(),
      newUsersThisMonth: (json['newUsersThisMonth'] as num).toInt(),
      totalShops: (json['totalShops'] as num).toInt(),
      activeShops: (json['activeShops'] as num).toInt(),
      pendingVerifications: (json['pendingVerifications'] as num).toInt(),
      totalProducts: (json['totalProducts'] as num).toInt(),
      activeProducts: (json['activeProducts'] as num).toInt(),
      totalConsignments: (json['totalConsignments'] as num).toInt(),
      activeConsignments: (json['activeConsignments'] as num).toInt(),
      expiringConsignments: (json['expiringConsignments'] as num).toInt(),
      totalGMV: (json['totalGMV'] as num).toDouble(),
      monthlyGMV: (json['monthlyGMV'] as num).toDouble(),
      platformRevenue: (json['platformRevenue'] as num).toDouble(),
      totalTransactions: (json['totalTransactions'] as num).toInt(),
      userGrowthRate: (json['userGrowthRate'] as num).toDouble(),
      revenueGrowthRate: (json['revenueGrowthRate'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        totalUsers,
        totalShops,
        totalGMV,
      ];
}
