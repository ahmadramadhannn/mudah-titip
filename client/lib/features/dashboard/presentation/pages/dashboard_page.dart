import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/widgets/notification_badge.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../bloc/dashboard_bloc.dart';

/// Dashboard page - main screen after login.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  DashboardBloc(
                    getIt<DashboardRepository>(),
                    getIt<ProductRepository>(),
                  )..add(
                    DashboardLoadRequested(isConsignor: authState.isConsignor),
                  ),
            ),
            BlocProvider.value(
              value: getIt<NotificationBloc>()..add(LoadUnreadCount()),
            ),
          ],
          child: _DashboardContent(auth: authState),
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final AuthAuthenticated auth;

  const _DashboardContent({required this.auth});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          // Notification bell with badge
          IconButton(
            icon: NotificationBadge(child: Icon(Icons.notifications_outlined)),
            onPressed: () => context.push('/notifications'),
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                context.push('/profile');
              } else if (value == 'logout') {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      auth.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.profile),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.logout),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            // Refresh dashboard when a product is added, updated, or deleted
            context.read<DashboardBloc>().add(
              DashboardRefreshRequested(isConsignor: auth.isConsignor),
            );
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<DashboardBloc>().add(
                        DashboardLoadRequested(isConsignor: auth.isConsignor),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(
                    DashboardRefreshRequested(isConsignor: auth.isConsignor),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      _GreetingCard(auth: auth),
                      const SizedBox(height: 24),

                      // Quick stats
                      Text(
                        l10n.summary,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _StatsGrid(auth: auth, state: state),
                      const SizedBox(height: 24),

                      // Quick actions
                      Text(
                        l10n.quickActions,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _QuickActionsGrid(auth: auth),
                      const SizedBox(height: 24),

                      // Alerts section
                      if (state.expiringConsignments.isNotEmpty ||
                          state.lowStockConsignments.isNotEmpty) ...[
                        Text(
                          l10n.attention,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _AlertsSection(state: state),
                      ],
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: _BottomNavBar(auth: auth),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final AuthAuthenticated auth;

  const _BottomNavBar({required this.auth});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            if (auth.isConsignor) {
              context.push('/products');
            } else {
              context.push('/consignments');
            }
            break;
          case 2:
            context.push('/sales');
            break;
          case 3:
            context.push('/agreements');
            break;
        }
      },
      destinations: auth.isConsignor
          ? [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: l10n.dashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.inventory_2_outlined),
                selectedIcon: const Icon(Icons.inventory_2),
                label: l10n.products,
              ),
              NavigationDestination(
                icon: const Icon(Icons.local_shipping_outlined),
                selectedIcon: const Icon(Icons.local_shipping),
                label: l10n.consignments,
              ),
              NavigationDestination(
                icon: const Icon(Icons.handshake_outlined),
                selectedIcon: const Icon(Icons.handshake),
                label: l10n.agreements,
              ),
            ]
          : [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: l10n.dashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.local_shipping_outlined),
                selectedIcon: const Icon(Icons.local_shipping),
                label: l10n.consignments,
              ),
              NavigationDestination(
                icon: const Icon(Icons.point_of_sale_outlined),
                selectedIcon: const Icon(Icons.point_of_sale),
                label: l10n.sales,
              ),
              NavigationDestination(
                icon: const Icon(Icons.handshake_outlined),
                selectedIcon: const Icon(Icons.handshake),
                label: l10n.agreements,
              ),
            ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final AuthAuthenticated auth;

  const _GreetingCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = l10n.goodMorning;
    } else if (hour < 15) {
      greeting = l10n.goodAfternoon;
    } else if (hour < 18) {
      greeting = l10n.goodEvening;
    } else {
      greeting = l10n.goodNight;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    auth.role.displayName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            auth.isConsignor ? Icons.inventory_2 : Icons.storefront,
            size: 48,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AuthAuthenticated auth;
  final DashboardLoaded state;

  const _StatsGrid({required this.auth, required this.state});

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} rb';
    }
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final stats = auth.isConsignor
        ? [
            _StatItem(
              l10n.totalProducts,
              state.totalProducts.toString(),
              Icons.inventory_2_outlined,
            ),
            _StatItem(
              l10n.activeConsignments,
              state.activeConsignments.length.toString(),
              Icons.local_shipping_outlined,
            ),
            _StatItem(
              l10n.sold,
              state.summary.totalItemsSold.toString(),
              Icons.sell_outlined,
            ),
            _StatItem(
              l10n.earnings,
              _formatCurrency(state.summary.totalEarnings),
              Icons.payments_outlined,
            ),
          ]
        : [
            _StatItem(
              l10n.activeConsignments,
              state.activeConsignments.length.toString(),
              Icons.local_shipping_outlined,
            ),
            _StatItem(
              l10n.sold,
              '${state.summary.totalItemsSold} item',
              Icons.today_outlined,
            ),
            _StatItem(
              l10n.commission,
              _formatCurrency(state.summary.totalEarnings),
              Icons.payments_outlined,
            ),
            _StatItem(
              l10n.lowStock,
              state.lowStockConsignments.length.toString(),
              Icons.warning_outlined,
            ),
          ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _StatCard(stat: stats[index]),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;

  _StatItem(this.label, this.value, this.icon);
}

class _StatCard extends StatelessWidget {
  final _StatItem stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Icon(stat.icon, color: AppColors.primary, size: 24)],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  stat.label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.neutral500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final AuthAuthenticated auth;

  const _QuickActionsGrid({required this.auth});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final actions = auth.isConsignor
        ? [
            _QuickAction(
              l10n.addProduct,
              Icons.add_box_outlined,
              '/products/add',
            ),
            _QuickAction(
              l10n.consign,
              Icons.upload_outlined,
              '/consignments/add',
            ),
            _QuickAction(l10n.viewSales, Icons.receipt_long_outlined, '/sales'),
            _QuickAction(
              l10n.analytics,
              Icons.analytics_outlined,
              '/analytics',
            ),
          ]
        : [
            _QuickAction(
              'Cari Produk', // Browse Products
              Icons.search_outlined,
              '/products/browse',
            ),
            _QuickAction(
              l10n.manageConsignors,
              Icons.people_outline,
              '/guest-consignors',
            ),
            _QuickAction(
              l10n.recordSale,
              Icons.add_shopping_cart,
              '/sales/add',
            ),
            _QuickAction(
              l10n.analytics,
              Icons.analytics_outlined,
              '/analytics',
            ),
          ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) =>
          _QuickActionButton(action: actions[index]),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final String route;

  _QuickAction(this.label, this.icon, this.route);
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(action.route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 4),
            Text(
              action.label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertsSection extends StatelessWidget {
  final DashboardLoaded state;

  const _AlertsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        if (state.expiringConsignments.isNotEmpty)
          _AlertCard(
            icon: Icons.schedule,
            iconColor: AppColors.warning,
            title: l10n.expiringConsignments(state.expiringConsignments.length),
            subtitle: l10n.checkAndTakeAction,
            onTap: () => context.push('/consignments'),
          ),
        if (state.lowStockConsignments.isNotEmpty) ...[
          const SizedBox(height: 8),
          _AlertCard(
            icon: Icons.inventory_outlined,
            iconColor: AppColors.error,
            title: l10n.lowStockConsignments(state.lowStockConsignments.length),
            subtitle: l10n.needRestockOrWithdraw,
            onTap: () => context.push('/consignments'),
          ),
        ],
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AlertCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: iconColor.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}
