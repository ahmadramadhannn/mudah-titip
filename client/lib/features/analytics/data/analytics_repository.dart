import '../../../core/api/api_client.dart';
import 'models/analytics_models.dart';

/// Repository for analytics data.
class AnalyticsRepository {
  final ApiClient _apiClient;

  AnalyticsRepository(this._apiClient);

  /// Get daily sales trend.
  Future<List<TrendData>> getTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String path = '/analytics/trends';
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
        .map((json) => TrendData.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get top performing products.
  Future<List<TopProduct>> getTopProducts({
    int limit = 5,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String path = '/analytics/top-products';
    final params = <String, String>{'limit': '$limit'};

    if (startDate != null) {
      params['startDate'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      params['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    path += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    final response = await _apiClient.get<List<dynamic>>(path);

    return (response.data ?? [])
        .map((json) => TopProduct.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get earnings breakdown by product.
  Future<List<EarningsBreakdown>> getBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String path = '/analytics/breakdown';
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
        .map((json) => EarningsBreakdown.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
