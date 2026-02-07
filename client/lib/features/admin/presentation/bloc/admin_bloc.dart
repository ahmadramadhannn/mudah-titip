import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

/// BLoC for admin operations
@injectable
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repository;

  AdminBloc(this._repository) : super(const AdminInitial()) {
    on<LoadPlatformMetrics>(_onLoadPlatformMetrics);
    on<LoadUsers>(_onLoadUsers);
    on<LoadUserDetails>(_onLoadUserDetails);
    on<SuspendUser>(_onSuspendUser);
    on<ActivateUser>(_onActivateUser);
    on<BanUser>(_onBanUser);
    on<LoadShops>(_onLoadShops);
    on<LoadPendingVerifications>(_onLoadPendingVerifications);
    on<VerifyShop>(_onVerifyShop);
    on<RejectShop>(_onRejectShop);
  }

  // ============================================================
  // Platform Metrics
  // ============================================================

  Future<void> _onLoadPlatformMetrics(
    LoadPlatformMetrics event,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(const AdminLoading());
      final metrics = await _repository.getPlatformMetrics();
      emit(PlatformMetricsLoaded(metrics));
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        emit(
          const AdminError(
            'Access denied. You do not have admin permissions. '
            'Please log out and log in with an admin account.',
          ),
        );
      } else if (e.response?.statusCode == 401) {
        emit(
          const AdminError('Session expired. Please log out and log in again.'),
        );
      } else {
        emit(AdminError('Failed to load platform metrics: ${e.message}'));
      }
    } catch (e) {
      emit(AdminError('Failed to load platform metrics: ${e.toString()}'));
    }
  }

  // ============================================================
  // User Management
  // ============================================================

  Future<void> _onLoadUsers(LoadUsers event, Emitter<AdminState> emit) async {
    try {
      emit(const AdminLoading());
      final users = await _repository.getAllUsers(
        role: event.role,
        status: event.status,
        page: event.page,
      );
      emit(
        UsersLoaded(
          users: users,
          currentPage: event.page,
          hasMore: users.length >= 20,
        ),
      );
    } catch (e) {
      emit(AdminError('Failed to load users: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUserDetails(
    LoadUserDetails event,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(const AdminLoading());
      final user = await _repository.getUserDetails(event.userId);
      emit(UserDetailsLoaded(user));
    } catch (e) {
      emit(AdminError('Failed to load user details: ${e.toString()}'));
    }
  }

  Future<void> _onSuspendUser(
    SuspendUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(const AdminLoading());
      await _repository.suspendUser(event.userId, event.reason);
      emit(const UserActionSuccess('User suspended successfully'));
    } catch (e) {
      emit(AdminError('Failed to suspend user: ${e.toString()}'));
    }
  }

  Future<void> _onActivateUser(
    ActivateUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(const AdminLoading());
      await _repository.activateUser(event.userId);
      emit(const UserActionSuccess('User activated successfully'));
    } catch (e) {
      emit(AdminError('Failed to activate user: ${e.toString()}'));
    }
  }

  Future<void> _onBanUser(BanUser event, Emitter<AdminState> emit) async {
    try {
      emit(const AdminLoading());
      await _repository.banUser(event.userId, event.reason);
      emit(const UserActionSuccess('User banned successfully'));
    } catch (e) {
      emit(AdminError('Failed to ban user: ${e.toString()}'));
    }
  }

  // ============================================================
  // Shop Management
  // ============================================================

  Future<void> _onLoadShops(LoadShops event, Emitter<AdminState> emit) async {
    try {
      emit(const AdminLoading());
      final shops = await _repository.getAllShops(
        verified: event.verified,
        page: event.page,
      );
      emit(
        ShopsLoaded(
          shops: shops,
          currentPage: event.page,
          hasMore: shops.length >= 20,
        ),
      );
    } catch (e) {
      emit(AdminError('Failed to load shops: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPendingVerifications(
    LoadPendingVerifications event,
    Emitter<AdminState> emit,
  ) async {
    try {
      emit(const AdminLoading());
      final shops = await _repository.getPendingVerifications();
      emit(PendingVerificationsLoaded(shops));
    } catch (e) {
      emit(AdminError('Failed to load pending verifications: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyShop(VerifyShop event, Emitter<AdminState> emit) async {
    try {
      emit(const AdminLoading());
      await _repository.verifyShop(event.shopId, event.message);
      emit(const ShopActionSuccess('Shop verified successfully'));
    } catch (e) {
      emit(AdminError('Failed to verify shop: ${e.toString()}'));
    }
  }

  Future<void> _onRejectShop(RejectShop event, Emitter<AdminState> emit) async {
    try {
      emit(const AdminLoading());
      await _repository.rejectShop(event.shopId, event.message);
      emit(const ShopActionSuccess('Shop verification rejected'));
    } catch (e) {
      emit(AdminError('Failed to reject shop: ${e.toString()}'));
    }
  }
}
