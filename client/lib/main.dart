import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/api/api_client.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/products/data/repositories/product_repository.dart';
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
  late final AuthBloc _authBloc;
  late final ProductBloc _productBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    final apiClient = getIt<ApiClient>();
    _authBloc = AuthBloc(AuthRepository(apiClient, getIt()));
    _productBloc = ProductBloc(ProductRepository(apiClient));
    _appRouter = AppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _productBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _productBloc),
      ],
      child: MaterialApp.router(
        title: 'Mudah Titip',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
