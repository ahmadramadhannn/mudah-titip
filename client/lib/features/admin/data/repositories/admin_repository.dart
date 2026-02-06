import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/user_admin.dart';
import '../models/shop_admin.dart';
import '../models/platform_metrics.dart';

/// Repository for admin operations
@injectable
class AdminRepository {
  final Dio _dio;

  AdminRepository(this._dio);

  // ============================================================
  // User Management
  // ============================================================

  /// Get all users with optional filtering
  Future<List<UserAdmin>> getAllUsers({
    String? role,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/admin/users',
      queryParameters: {
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        'page': page,
        'size': size,
      },
    );

    final content = response.data['content'] as List;
    return content.map((json) => UserAdmin.fromJson(json)).toList();
  }

  /// Get detailed user information
  Future<UserAdmin> getUserDetails(int userId) async {
    final response = await _dio.get('/admin/users/$userId');
    return UserAdmin.fromJson(response.data);
  }

  /// Suspend a user account
  Future<void> suspendUser(int userId, String reason) async {
    await _dio.put(
      '/admin/users/$userId/suspend',
      data: {'action': 'SUSPEND', 'reason': reason},
    );
  }

  /// Activate a suspended user account
  Future<void> activateUser(int userId) async {
    await _dio.put('/admin/users/$userId/activate');
  }

  /// Ban a user account permanently
  Future<void> banUser(int userId, String reason) async {
    await _dio.put(
      '/admin/users/$userId/ban',
      data: {'action': 'BAN', 'reason': reason},
    );
  }

  // ============================================================
  // Shop Management
  // ============================================================

  /// Get all shops with optional filtering
  Future<List<ShopAdmin>> getAllShops({
    bool? verified,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/admin/shops',
      queryParameters: {
        if (verified != null) 'verified': verified,
        'page': page,
        'size': size,
      },
    );

    final content = response.data['content'] as List;
    return content.map((json) => ShopAdmin.fromJson(json)).toList();
  }

  /// Get shops pending verification
  Future<List<ShopAdmin>> getPendingVerifications() async {
    final response = await _dio.get('/admin/shops/pending');
    final data = response.data as List;
    return data.map((json) => ShopAdmin.fromJson(json)).toList();
  }

  /// Verify a shop
  Future<void> verifyShop(int shopId, String message) async {
    await _dio.put(
      '/admin/shops/$shopId/verify',
      data: {'approved': true, 'message': message},
    );
  }

  /// Reject a shop verification
  Future<void> rejectShop(int shopId, String message) async {
    await _dio.put(
      '/admin/shops/$shopId/reject',
      data: {'approved': false, 'message': message},
    );
  }

  // ============================================================
  // Analytics
  // ============================================================

  /// Get platform-wide metrics
  Future<PlatformMetrics> getPlatformMetrics() async {
    final response = await _dio.get('/admin/analytics/overview');
    return PlatformMetrics.fromJson(response.data);
  }
}
