import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_error_handler.dart';
import '../models/product.dart';
import '../models/product_request.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<List<Product>> getMyProducts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myProducts);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  Future<Product> getProduct(int id) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.product(id.toString()),
      );
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  Future<Product> createProduct(CreateProductRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.products,
        data: request.toJson(),
      );
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  Future<Product> updateProduct(int id, UpdateProductRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.product(id.toString()),
        data: request.toJson(),
      );
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _apiClient.delete(ApiEndpoints.product(id.toString()));
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}
