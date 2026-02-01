import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'core/api/api_client.dart';
import 'core/di/injection.dart';
import 'core/locale/locale_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MudahTitipApp());
}

class MudahTitipApp extends StatefulWidget {
  const MudahTitipApp({super.key});

  @override
  State<MudahTitipApp> createState() => _MudahTitipAppState();
}

class _MudahTitipAppState extends State<MudahTitipApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    // AuthBloc is a singleton from DI, used for router refresh
    _appRouter = AppRouter(getIt<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // LocaleCubit is singleton for app-wide locale management
        BlocProvider.value(value: getIt<LocaleCubit>()),
        // AuthBloc is singleton - use value provider
        BlocProvider.value(value: getIt<AuthBloc>()),
        // ProductBloc is registered as lazy singleton in DI
        BlocProvider(create: (_) => getIt<ProductBloc>()),
      ],
      // Rebuild MaterialApp when locale changes
      child: BlocConsumer<LocaleCubit, LocaleState>(
        listener: (context, state) {
          // Sync API client locale when locale changes
          if (kDebugMode) {
            print(
              '🌐 BlocConsumer listener: locale changed to ${state.locale.languageCode}',
            );
          }
          getIt<ApiClient>().setLocale(state.locale.languageCode);
        },
        builder: (context, localeState) {
          if (kDebugMode) {
            print(
              '🌐 BlocConsumer builder: building with locale ${localeState.locale.languageCode}',
            );
          }
          return MaterialApp.router(
            title: 'Mudah Titip',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            routerConfig: _appRouter.router,
            // Use locale from LocaleCubit
            locale: localeState.locale,
            // Localization
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('id'), // Indonesian (default)
              Locale('en'), // English
            ],
          );
        },
      ),
    );
  }
}
