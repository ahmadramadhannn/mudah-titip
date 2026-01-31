import 'package:equatable/equatable.dart';

/// Dashboard summary model matching backend /api/sales/summary response.
class DashboardSummary extends Equatable {
  final double totalEarnings;
  final int totalSales;
  final int totalItemsSold;
  final DateTime startDate;
  final DateTime endDate;

  const DashboardSummary({
    required this.totalEarnings,
    required this.totalSales,
    required this.totalItemsSold,
    required this.startDate,
    required this.endDate,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      totalSales: json['totalSales'] as int? ?? 0,
      totalItemsSold: json['totalItemsSold'] as int? ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  /// Empty summary for initial/error states.
  static DashboardSummary empty() {
    final now = DateTime.now();
    return DashboardSummary(
      totalEarnings: 0,
      totalSales: 0,
      totalItemsSold: 0,
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now,
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
