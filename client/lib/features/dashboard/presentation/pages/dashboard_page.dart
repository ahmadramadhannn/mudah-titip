import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../products/data/repositories/product_repository.dart';
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

        return BlocProvider(
          create: (context) => DashboardBloc(
            getIt<DashboardRepository>(),
            getIt<ProductRepository>(),
          )..add(DashboardLoadRequested(isConsignor: authState.isConsignor)),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mudah Titip'),
        actions: [
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
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Profil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Keluar'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
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
                    child: const Text('Coba Lagi'),
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
                      'Ringkasan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _StatsGrid(auth: auth, state: state),
                    const SizedBox(height: 24),

                    // Quick actions
                    Text(
                      'Aksi Cepat',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _QuickActionsGrid(auth: auth),
                    const SizedBox(height: 24),

                    // Alerts section
                    if (state.expiringConsignments.isNotEmpty ||
                        state.lowStockConsignments.isNotEmpty) ...[
                      Text(
                        'Perhatian',
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
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
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
          ? const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Produk',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping),
                label: 'Titipan',
              ),
              NavigationDestination(
                icon: Icon(Icons.handshake_outlined),
                selectedIcon: Icon(Icons.handshake),
                label: 'Perjanjian',
              ),
            ]
          : const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping),
                label: 'Titipan',
              ),
              NavigationDestination(
                icon: Icon(Icons.point_of_sale_outlined),
                selectedIcon: Icon(Icons.point_of_sale),
                label: 'Penjualan',
              ),
              NavigationDestination(
                icon: Icon(Icons.handshake_outlined),
                selectedIcon: Icon(Icons.handshake),
                label: 'Perjanjian',
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
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
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
    final stats = auth.isConsignor
        ? [
            _StatItem(
              'Total Produk',
              state.totalProducts.toString(),
              Icons.inventory_2_outlined,
            ),
            _StatItem(
              'Titipan Aktif',
              state.activeConsignments.length.toString(),
              Icons.local_shipping_outlined,
            ),
            _StatItem(
              'Terjual',
              state.summary.totalItemsSold.toString(),
              Icons.sell_outlined,
            ),
            _StatItem(
              'Pendapatan',
              _formatCurrency(state.summary.totalEarnings),
              Icons.payments_outlined,
            ),
          ]
        : [
            _StatItem(
              'Titipan Aktif',
              state.activeConsignments.length.toString(),
              Icons.local_shipping_outlined,
            ),
            _StatItem(
              'Terjual',
              '${state.summary.totalItemsSold} item',
              Icons.today_outlined,
            ),
            _StatItem(
              'Komisi',
              _formatCurrency(state.summary.totalEarnings),
              Icons.payments_outlined,
            ),
            _StatItem(
              'Stok Rendah',
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
    final actions = auth.isConsignor
        ? [
            _QuickAction(
              'Tambah Produk',
              Icons.add_box_outlined,
              '/products/add',
            ),
            _QuickAction(
              'Titipkan',
              Icons.upload_outlined,
              '/consignments/add',
            ),
            _QuickAction(
              'Lihat Penjualan',
              Icons.receipt_long_outlined,
              '/sales',
            ),
            _QuickAction('Analytics', Icons.analytics_outlined, '/analytics'),
          ]
        : [
            _QuickAction(
              'Kelola Penitip',
              Icons.people_outline,
              '/guest-consignors',
            ),
            _QuickAction(
              'Catat Penjualan',
              Icons.add_shopping_cart,
              '/sales/add',
            ),
            _QuickAction('Analytics', Icons.analytics_outlined, '/analytics'),
            _QuickAction('Perjanjian', Icons.handshake_outlined, '/agreements'),
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
    return Column(
      children: [
        if (state.expiringConsignments.isNotEmpty)
          _AlertCard(
            icon: Icons.schedule,
            iconColor: AppColors.warning,
            title:
                '${state.expiringConsignments.length} titipan akan kedaluwarsa',
            subtitle: 'Segera periksa dan ambil tindakan',
            onTap: () => context.push('/consignments'),
          ),
        if (state.lowStockConsignments.isNotEmpty) ...[
          const SizedBox(height: 8),
          _AlertCard(
            icon: Icons.inventory_outlined,
            iconColor: AppColors.error,
            title: '${state.lowStockConsignments.length} stok titipan rendah',
            subtitle: 'Perlu restock atau tarik barang',
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
