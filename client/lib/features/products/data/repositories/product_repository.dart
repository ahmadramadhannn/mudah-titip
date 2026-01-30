import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../models/product.dart';
import '../models/product_request.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<List<Product>> getMyProducts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myProducts);
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Product> getProduct(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.product(id));
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Product> createProduct(CreateProductRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.products,
        data: request.toJson(),
      );
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Product> updateProduct(String id, UpdateProductRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.product(id),
        data: request.toJson(),
      );
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.product(id));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 400 || statusCode == 422) {
      final message = data is Map ? data['message'] as String? : null;
      return ValidationFailure(message ?? 'Data tidak valid');
    }

    return ServerFailure(
      data is Map
          ? data['message'] as String? ?? 'Terjadi kesalahan'
          : 'Terjadi kesalahan',
      statusCode: statusCode,
    );
  }
}
