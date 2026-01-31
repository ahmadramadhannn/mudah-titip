import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../models/consignment.dart';
import '../models/dashboard_summary.dart';

/// Repository for dashboard-related API calls.
class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  /// Get sales summary for the current user.
  Future<DashboardSummary> getSalesSummary() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.salesSummary);
      return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get consignments that are expiring soon.
  Future<List<Consignment>> getExpiringConsignments({int days = 7}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.expiringSoon,
        queryParameters: {'days': days},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Consignment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get all consignments for the current user.
  Future<List<Consignment>> getMyConsignments({
    ConsignmentStatus? status,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.myConsignments,
        queryParameters: status != null ? {'status': status.value} : null,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Consignment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get count of active consignments.
  Future<int> getActiveConsignmentCount() async {
    final consignments = await getMyConsignments(
      status: ConsignmentStatus.active,
    );
    return consignments.length;
  }

  /// Get consignments with low stock.
  Future<List<Consignment>> getLowStockConsignments({int threshold = 5}) async {
    final consignments = await getMyConsignments(
      status: ConsignmentStatus.active,
    );
    return consignments
        .where((c) => c.isLowStock(threshold: threshold))
        .toList();
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 401) {
      return const ServerFailure('Sesi Anda telah berakhir', statusCode: 401);
    }

    return ServerFailure(
      data is Map
          ? data['message'] as String? ?? 'Terjadi kesalahan'
          : 'Terjadi kesalahan',
      statusCode: statusCode,
    );
  }
}
