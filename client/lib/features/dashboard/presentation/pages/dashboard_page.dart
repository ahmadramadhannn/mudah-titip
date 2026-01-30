import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/models/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Dashboard page - main screen after login.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // final user = state.user;

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
                  if (value == 'logout') {
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
                          "john doe",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          "john doe",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
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
          body: RefreshIndicator(
            onRefresh: () async {
              // TODO: Refresh dashboard data
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  // _GreetingCard(user: user),
                  const SizedBox(height: 24),

                  // Quick stats
                  Text(
                    'Ringkasan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  // _StatsGrid(user: user),
                  const SizedBox(height: 24),

                  // Quick actions
                  Text(
                    'Aksi Cepat',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  // _QuickActionsGrid(user: user),
                  const SizedBox(height: 24),

                  // Alerts section
                  Text(
                    'Perhatian',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  // _AlertsCard(user: user),
                ],
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (index) {
              // switch (index) {
              //   case 0:
              //     // Already on dashboard
              //     break;
              //   case 1:
              //     if (user.isConsignor) {
              //       context.push('/products');
              //     } else {
              //       context.push('/consignments');
              //     }
              //     break;
              //   case 2:
              //     if (user.isShopOwner) {
              //       context.push('/sales');
              //     } else {
              //       context.push('/consignments');
              //     }
              //     break;
              //   case 3:
              //     context.push('/agreements');
              //     break;
              // }
            },
            destinations: 10 == 2
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
          ),
        );
      },
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final User user;

  const _GreetingCard({required this.user});

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
                  user.name,
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
                    user.role.displayName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            user.isConsignor ? Icons.inventory_2 : Icons.storefront,
            size: 48,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final User user;

  const _StatsGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    // Placeholder stats - will be replaced with real data
    final stats = user.isConsignor
        ? [
            _StatItem('Total Produk', '12', Icons.inventory_2_outlined),
            _StatItem('Titipan Aktif', '5', Icons.local_shipping_outlined),
            _StatItem('Terjual', '28', Icons.sell_outlined),
            _StatItem('Pendapatan', 'Rp 2.5 jt', Icons.payments_outlined),
          ]
        : [
            _StatItem('Titipan Aktif', '8', Icons.local_shipping_outlined),
            _StatItem('Hari Ini', '5 terjual', Icons.today_outlined),
            _StatItem('Komisi', 'Rp 350 rb', Icons.payments_outlined),
            _StatItem('Stok Rendah', '3', Icons.warning_outlined),
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
  final User user;

  const _QuickActionsGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    final actions = user.isConsignor
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
            _QuickAction('Perjanjian', Icons.handshake_outlined, '/agreements'),
          ]
        : [
            _QuickAction(
              'Catat Penjualan',
              Icons.add_shopping_cart,
              '/sales/add',
            ),
            _QuickAction(
              'Lihat Titipan',
              Icons.inventory_outlined,
              '/consignments',
            ),
            _QuickAction('Riwayat Penjualan', Icons.history_outlined, '/sales'),
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

class _AlertsCard extends StatelessWidget {
  final User user;

  const _AlertsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    // Placeholder alerts
    return Card(
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_rounded, color: AppColors.warning),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.isConsignor
                        ? '3 produk akan kedaluwarsa'
                        : '3 stok titipan rendah',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Segera periksa dan ambil tindakan',
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
    );
  }
}
