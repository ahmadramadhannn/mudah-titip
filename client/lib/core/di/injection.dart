import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../locale/locale_cubit.dart';
import '../services/image_upload_service.dart';
import '../../features/agreement/data/repositories/agreement_repository.dart';
import '../../features/agreement/presentation/bloc/agreement_bloc.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/consignment/data/consignment_repository.dart';
import '../../features/sale/data/sale_repository.dart';
import '../../features/analytics/data/analytics_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/guest_consignor/data/repositories/guest_consignor_repository.dart';
import '../../features/products/data/repositories/product_repository.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies.
Future<void> configureDependencies() async {
  // ============================================================
  // External Dependencies
  // ============================================================
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // ============================================================
  // Core
  // ============================================================
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // LocaleCubit (singleton to persist across app)
  getIt.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<ImageUploadService>(
    () => ImageUploadService(getIt<ApiClient>()),
  );

  // ============================================================
  // Repositories
  // ============================================================
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiClient>(), getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AgreementRepository>(
    () => AgreementRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<GuestConsignorRepository>(
    () => GuestConsignorRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ConsignmentRepository>(
    () => ConsignmentRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<SaleRepository>(
    () => SaleRepository(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepository(getIt<ApiClient>()),
  );

  // ============================================================
  // Blocs
  // ============================================================
  // AuthBloc is registered as singleton because it's used for router refresh
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(getIt<AuthRepository>()),
  );

  // Other blocs are registered as factory (new instance each time)
  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(getIt<ProductRepository>()),
  );

  getIt.registerFactory<DashboardBloc>(
    () =>
        DashboardBloc(getIt<DashboardRepository>(), getIt<ProductRepository>()),
  );

  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(getIt<ProfileRepository>()),
  );

  getIt.registerFactory<AgreementBloc>(
    () => AgreementBloc(getIt<AgreementRepository>()),
  );
}
