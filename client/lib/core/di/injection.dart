import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies.
Future<void> configureDependencies() async {
  // External
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Repositories will be registered here as we create them
}
