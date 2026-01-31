import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_error_handler.dart';
import '../models/guest_consignor.dart';
import '../models/guest_consignor_request.dart';

/// Repository for guest consignor operations.
class GuestConsignorRepository {
  final ApiClient _apiClient;

  GuestConsignorRepository(this._apiClient);

  /// Get all guest consignors for the current shop owner.
  Future<List<GuestConsignor>> getAll() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.guestConsignors);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => GuestConsignor.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Get a single guest consignor by ID.
  Future<GuestConsignor> getById(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.guestConsignor('$id'));
      return GuestConsignor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Create a new guest consignor.
  Future<GuestConsignor> create(GuestConsignorRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.guestConsignors,
        data: request.toJson(),
      );
      return GuestConsignor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Update an existing guest consignor.
  Future<GuestConsignor> update(int id, GuestConsignorRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.guestConsignor('$id'),
        data: request.toJson(),
      );
      return GuestConsignor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Delete (deactivate) a guest consignor.
  Future<void> delete(int id) async {
    try {
      await _apiClient.delete(ApiEndpoints.guestConsignor('$id'));
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Search guest consignors by phone or name.
  Future<List<GuestConsignor>> search({String? phone, String? name}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (phone != null && phone.isNotEmpty) {
        queryParams['phone'] = phone;
      } else if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }

      final response = await _apiClient.get(
        ApiEndpoints.searchGuestConsignors,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => GuestConsignor.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}
