import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_error_handler.dart';
import '../models/agreement.dart';
import '../models/agreement_request.dart';
import '../models/settlement_result.dart';

/// Repository for agreement operations.
class AgreementRepository {
  final ApiClient _apiClient;

  AgreementRepository(this._apiClient);

  /// Propose a new agreement for a consignment.
  Future<Agreement> propose(AgreementRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.proposeAgreement,
        data: request.toJson(),
      );
      return Agreement.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Counter an existing proposal with new terms.
  Future<Agreement> counter(int agreementId, AgreementRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.counterAgreement(agreementId.toString()),
        data: request.toJson(),
      );
      return Agreement.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Accept a proposal.
  Future<Agreement> accept(int agreementId, {String? message}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.acceptAgreement(agreementId.toString()),
        data: message != null ? {'message': message} : null,
      );
      return Agreement.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Reject a proposal.
  Future<Agreement> reject(int agreementId, {String? reason}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.rejectAgreement(agreementId.toString()),
        data: reason != null ? {'reason': reason} : null,
      );
      return Agreement.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Get pending agreements for current user to respond to.
  Future<List<Agreement>> getPendingAgreements() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.pendingAgreements);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Agreement.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Calculate settlement for a consignment.
  Future<SettlementResult> getSettlement(int consignmentId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.settlement(consignmentId.toString()),
      );
      return SettlementResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}
