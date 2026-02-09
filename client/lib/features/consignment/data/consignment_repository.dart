import '../../../core/api/api_client.dart';
import 'models/consignment.dart';
import 'models/consignment_request.dart';

/// Repository for consignment operations.
class ConsignmentRepository {
  final ApiClient _apiClient;

  ConsignmentRepository(this._apiClient);

  /// Get all consignments for the current user.
  /// Optionally filter by status.
  Future<List<Consignment>> getMyConsignments({
    ConsignmentStatus? status,
  }) async {
    String path = '/consignments/my';
    if (status != null) {
      path += '?status=${status.name.toUpperCase()}';
    }

    final response = await _apiClient.get<List<dynamic>>(path);

    return (response.data ?? [])
        .map((json) => Consignment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a single consignment by ID.
  Future<Consignment> getConsignment(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/consignments/$id',
    );

    return Consignment.fromJson(response.data!);
  }

  /// Create a new consignment. (Consignor only)
  Future<Consignment> createConsignment(ConsignmentRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/consignments',
      data: request.toJson(),
    );

    return Consignment.fromJson(response.data!);
  }

  /// Update consignment status.
  Future<Consignment> updateStatus(int id, ConsignmentStatus status) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/consignments/$id/status?status=${status.name.toUpperCase()}',
    );

    return Consignment.fromJson(response.data!);
  }

  /// Get consignments expiring within the given number of days.
  Future<List<Consignment>> getExpiringSoon({int days = 7}) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/consignments/expiring?days=$days',
    );

    return (response.data ?? [])
        .map((json) => Consignment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get consignments without an accepted agreement (eligible for proposals).
  Future<List<Consignment>> getConsignmentsWithoutAgreement() async {
    final response = await _apiClient.get<List<dynamic>>(
      '/consignments/without-agreement',
    );

    return (response.data ?? [])
        .map((json) => Consignment.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
