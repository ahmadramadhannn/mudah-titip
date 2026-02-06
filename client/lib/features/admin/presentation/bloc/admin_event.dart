import 'package:equatable/equatable.dart';

/// Base class for admin events
abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// Platform Metrics Events
// ============================================================

/// Load platform metrics
class LoadPlatformMetrics extends AdminEvent {
  const LoadPlatformMetrics();
}

// ============================================================
// User Management Events
// ============================================================

/// Load all users
class LoadUsers extends AdminEvent {
  final String? role;
  final String? status;
  final int page;

  const LoadUsers({this.role, this.status, this.page = 0});

  @override
  List<Object?> get props => [role, status, page];
}

/// Load user details
class LoadUserDetails extends AdminEvent {
  final int userId;

  const LoadUserDetails(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Suspend user
class SuspendUser extends AdminEvent {
  final int userId;
  final String reason;

  const SuspendUser(this.userId, this.reason);

  @override
  List<Object?> get props => [userId, reason];
}

/// Activate user
class ActivateUser extends AdminEvent {
  final int userId;

  const ActivateUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Ban user
class BanUser extends AdminEvent {
  final int userId;
  final String reason;

  const BanUser(this.userId, this.reason);

  @override
  List<Object?> get props => [userId, reason];
}

// ============================================================
// Shop Management Events
// ============================================================

/// Load all shops
class LoadShops extends AdminEvent {
  final bool? verified;
  final int page;

  const LoadShops({this.verified, this.page = 0});

  @override
  List<Object?> get props => [verified, page];
}

/// Load pending shop verifications
class LoadPendingVerifications extends AdminEvent {
  const LoadPendingVerifications();
}

/// Verify shop
class VerifyShop extends AdminEvent {
  final int shopId;
  final String message;

  const VerifyShop(this.shopId, this.message);

  @override
  List<Object?> get props => [shopId, message];
}

/// Reject shop
class RejectShop extends AdminEvent {
  final int shopId;
  final String message;

  const RejectShop(this.shopId, this.message);

  @override
  List<Object?> get props => [shopId, message];
}
