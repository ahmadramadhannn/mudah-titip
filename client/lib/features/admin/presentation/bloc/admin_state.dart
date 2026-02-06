import 'package:equatable/equatable.dart';
import '../../data/models/user_admin.dart';
import '../../data/models/shop_admin.dart';
import '../../data/models/platform_metrics.dart';

/// Base class for admin states
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminInitial extends AdminState {
  const AdminInitial();
}

/// Loading state
class AdminLoading extends AdminState {
  const AdminLoading();
}

/// Error state
class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// Platform Metrics States
// ============================================================

/// Platform metrics loaded
class PlatformMetricsLoaded extends AdminState {
  final PlatformMetrics metrics;

  const PlatformMetricsLoaded(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

// ============================================================
// User Management States
// ============================================================

/// Users loaded
class UsersLoaded extends AdminState {
  final List<UserAdmin> users;
  final int currentPage;
  final bool hasMore;

  const UsersLoaded({
    required this.users,
    required this.currentPage,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [users, currentPage, hasMore];
}

/// User details loaded
class UserDetailsLoaded extends AdminState {
  final UserAdmin user;

  const UserDetailsLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// User action success
class UserActionSuccess extends AdminState {
  final String message;

  const UserActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// Shop Management States
// ============================================================

/// Shops loaded
class ShopsLoaded extends AdminState {
  final List<ShopAdmin> shops;
  final int currentPage;
  final bool hasMore;

  const ShopsLoaded({
    required this.shops,
    required this.currentPage,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [shops, currentPage, hasMore];
}

/// Pending verifications loaded
class PendingVerificationsLoaded extends AdminState {
  final List<ShopAdmin> shops;

  const PendingVerificationsLoaded(this.shops);

  @override
  List<Object?> get props => [shops];
}

/// Shop action success
class ShopActionSuccess extends AdminState {
  final String message;

  const ShopActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
