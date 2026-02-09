import '../../../../core/api/api_client.dart';
import '../models/complaint_model.dart';

/// Repository for complaint API operations.
class ComplaintRepository {
  final ApiClient _apiClient;

  ComplaintRepository(this._apiClient);

  /// Create a new complaint.
  Future<ComplaintModel> createComplaint({
    required int consignmentId,
    required ComplaintCategory category,
    required String description,
    List<String>? mediaUrls,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/complaints',
      data: {
        'consignmentId': consignmentId,
        'category': category.value,
        'description': description,
        'mediaUrls': mediaUrls ?? [],
      },
    );
    return ComplaintModel.fromJson(response.data!);
  }

  /// Get all complaints for the current user (role-based).
  Future<List<ComplaintModel>> getComplaints() async {
    final response = await _apiClient.get<List<dynamic>>('/complaints');
    return (response.data ?? [])
        .map((json) => ComplaintModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific complaint by ID.
  Future<ComplaintModel> getComplaint(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/complaints/$id',
    );
    return ComplaintModel.fromJson(response.data!);
  }

  /// Resolve a complaint (consignor only).
  Future<ComplaintModel> resolveComplaint({
    required int id,
    required String resolution,
    required bool accepted,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/complaints/$id/resolve',
      data: {'resolution': resolution, 'accepted': accepted},
    );
    return ComplaintModel.fromJson(response.data!);
  }

  /// Get count of open complaints.
  Future<int> getOpenComplaintsCount() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/complaints/count/open',
    );
    return (response.data?['count'] as int?) ?? 0;
  }
}
