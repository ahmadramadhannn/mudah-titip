import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../../core/theme/app_colors.dart';

/// Admin dashboard overview page
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load platform metrics on init
    context.read<AdminBloc>().add(const LoadPlatformMetrics());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
              _handleNavigation(index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.store_outlined),
                selectedIcon: Icon(Icons.store),
                label: Text('Shops'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // Main content area
          Expanded(
            child: _selectedIndex == 0
                ? _buildOverviewContent()
                : Center(
                    child: Text('Feature coming soon: ${_getPageTitle()}'),
                  ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Overview';
      case 1:
        return 'Users';
      case 2:
        return 'Shops';
      case 3:
        return 'Analytics';
      default:
        return '';
    }
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        context.read<AdminBloc>().add(const LoadPlatformMetrics());
        break;
      case 1:
        context.read<AdminBloc>().add(const LoadUsers());
        break;
      case 2:
        context.read<AdminBloc>().add(const LoadShops());
        break;
      case 3:
        // Analytics
        break;
    }
  }

  Widget _buildOverviewContent() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminBloc>().add(const LoadPlatformMetrics());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is PlatformMetricsLoaded) {
          return _buildMetricsGrid(state.metrics);
        }

        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildMetricsGrid(metrics) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Platform Overview',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<AdminBloc>().add(const LoadPlatformMetrics());
                },
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Metrics grid
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _MetricCard(
                title: 'Total Users',
                value: metrics.totalUsers.toString(),
                icon: Icons.people,
                color: AppColors.primary,
                subtitle: '+${metrics.newUsersThisMonth} this month',
              ),
              _MetricCard(
                title: 'Active Shops',
                value: metrics.activeShops.toString(),
                icon: Icons.store,
                color: AppColors.secondary,
                subtitle: '${metrics.totalShops} total',
              ),
              _MetricCard(
                title: 'Total GMV',
                value: currencyFormat.format(metrics.totalGMV),
                icon: Icons.payments,
                color: AppColors.success,
                subtitle:
                    currencyFormat.format(metrics.monthlyGMV) + ' monthly',
              ),
              _MetricCard(
                title: 'Pending Verifications',
                value: metrics.pendingVerifications.toString(),
                icon: Icons.pending_actions,
                color: AppColors.warning,
                subtitle: 'Shops awaiting approval',
              ),
              _MetricCard(
                title: 'Shop Owners',
                value: metrics.totalShopOwners.toString(),
                icon: Icons.business,
                color: AppColors.primary,
              ),
              _MetricCard(
                title: 'Consignors',
                value: metrics.totalConsignors.toString(),
                icon: Icons.person,
                color: AppColors.secondary,
              ),
              _MetricCard(
                title: 'Active Products',
                value: metrics.activeProducts.toString(),
                icon: Icons.inventory,
                color: AppColors.success,
                subtitle: '${metrics.totalProducts} total',
              ),
              _MetricCard(
                title: 'Active Consignments',
                value: metrics.activeConsignments.toString(),
                icon: Icons.local_shipping,
                color: AppColors.info,
                subtitle: '${metrics.expiringConsignments} expiring soon',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: color),
                const Spacer(),
                if (subtitle != null)
                  const Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.success,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 10, color: AppColors.neutral500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
