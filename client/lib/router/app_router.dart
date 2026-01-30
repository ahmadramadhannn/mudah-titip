import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/products/data/models/product.dart';
import '../features/products/presentation/pages/add_product_page.dart';
import '../features/products/presentation/pages/products_page.dart';

/// App router configuration using go_router.
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is AuthAuthenticated;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/';

      // If on splash and auth check complete, redirect accordingly
      if (isSplash && authState is! AuthInitial && authState is! AuthLoading) {
        return isAuth ? '/dashboard' : '/login';
      }

      // If not authenticated and not on login/register, go to login
      if (!isAuth && !isLoggingIn && !isSplash) {
        return '/login';
      }

      // If authenticated and on login/register, go to dashboard
      if (isAuth && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      // Placeholder routes - will be implemented later
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/products/add',
        builder: (context, state) {
          final product = state.extra as Product?;
          return AddProductPage(productToEdit: product);
        },
      ),
      GoRoute(
        path: '/consignments',
        builder: (context, state) => _PlaceholderPage(title: 'Titipan'),
      ),
      GoRoute(
        path: '/consignments/add',
        builder: (context, state) => _PlaceholderPage(title: 'Titipkan Produk'),
      ),
      GoRoute(
        path: '/sales',
        builder: (context, state) => _PlaceholderPage(title: 'Penjualan'),
      ),
      GoRoute(
        path: '/sales/add',
        builder: (context, state) => _PlaceholderPage(title: 'Catat Penjualan'),
      ),
      GoRoute(
        path: '/agreements',
        builder: (context, state) => _PlaceholderPage(title: 'Perjanjian'),
      ),
    ],
  );
}

/// Stream wrapper for GoRouter refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.listen((_) => notifyListeners());
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Halaman $title',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Segera hadir',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
