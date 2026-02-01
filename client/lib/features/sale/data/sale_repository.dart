import '../../../core/api/api_client.dart';
import 'models/sale.dart';
import 'models/sale_request.dart';

/// Repository for sale operations.
class SaleRepository {
  final ApiClient _apiClient;

  SaleRepository(this._apiClient);

  /// Get sales for the current user.
  /// Shop owners see sales at their shop.
  /// Consignors see sales of their products.
  Future<List<Sale>> getMySales({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String path = '/sales/my';
    final params = <String, String>{};

    if (startDate != null) {
      params['startDate'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      params['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    if (params.isNotEmpty) {
      path += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    final response = await _apiClient.get<List<dynamic>>(path);

    return (response.data ?? [])
        .map((json) => Sale.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Record a new sale. (Shop owner only)
  Future<Sale> recordSale(SaleRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/sales',
      data: request.toJson(),
    );

    return Sale.fromJson(response.data!);
  }

  /// Get earnings summary for current user.
  Future<SalesSummary> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String path = '/sales/summary';
    final params = <String, String>{};

    if (startDate != null) {
      params['startDate'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      params['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    if (params.isNotEmpty) {
      path += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    final response = await _apiClient.get<Map<String, dynamic>>(path);

    return SalesSummary.fromJson(response.data!);
  }
}
