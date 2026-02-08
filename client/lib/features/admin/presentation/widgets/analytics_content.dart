import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../data/models/platform_metrics.dart';
import '../../../../core/theme/app_colors.dart';

/// Analytics content widget for admin dashboard.
/// Shows platform metrics with visual charts and statistics.
class AnalyticsContent extends StatefulWidget {
  const AnalyticsContent({super.key});

  @override
  State<AnalyticsContent> createState() => _AnalyticsContentState();
}

class _AnalyticsContentState extends State<AnalyticsContent> {
  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  void _loadMetrics() {
    context.read<AdminBloc>().add(const LoadPlatformMetrics());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PlatformMetricsLoaded) {
          return _buildAnalyticsView(state.metrics);
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: AppColors.neutral400,
              ),
              const SizedBox(height: 16),
              const Text('Load analytics data'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadMetrics,
                icon: const Icon(Icons.refresh),
                label: const Text('Load Analytics'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsView(PlatformMetrics metrics) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return RefreshIndicator(
      onRefresh: () async => _loadMetrics(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Platform Analytics',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadMetrics,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary Cards
            _buildSummarySection(metrics, currencyFormat),
            const SizedBox(height: 32),

            // Revenue Section
            _buildRevenueSection(metrics, currencyFormat),
            const SizedBox(height: 32),

            // User Distribution
            _buildUserDistributionSection(metrics),
            const SizedBox(height: 32),

            // Growth Metrics
            _buildGrowthSection(metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    PlatformMetrics metrics,
    NumberFormat currencyFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _SummaryCard(
              title: 'Total GMV',
              value: currencyFormat.format(metrics.totalGMV),
              icon: Icons.attach_money,
              color: AppColors.success,
            ),
            _SummaryCard(
              title: 'Total Users',
              value: metrics.totalUsers.toString(),
              icon: Icons.people,
              color: AppColors.primary,
            ),
            _SummaryCard(
              title: 'Total Products',
              value: metrics.totalProducts.toString(),
              icon: Icons.inventory_2,
              color: AppColors.secondary,
            ),
            _SummaryCard(
              title: 'Transactions',
              value: metrics.totalTransactions.toString(),
              icon: Icons.shopping_cart,
              color: AppColors.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueSection(
    PlatformMetrics metrics,
    NumberFormat currencyFormat,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: AppColors.success),
                const SizedBox(width: 8),
                const Text(
                  'Revenue Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _RevenueMetric(
                    label: 'Total GMV',
                    value: currencyFormat.format(metrics.totalGMV),
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _RevenueMetric(
                    label: 'Platform Revenue',
                    value: currencyFormat.format(metrics.platformRevenue),
                    icon: Icons.percent,
                  ),
                ),
                Expanded(
                  child: _RevenueMetric(
                    label: 'Monthly GMV',
                    value: currencyFormat.format(metrics.monthlyGMV),
                    icon: Icons.calendar_today,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Revenue bar chart placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Revenue Chart',
                      style: TextStyle(color: AppColors.neutral600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Historical data coming soon',
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDistributionSection(PlatformMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'User Distribution',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                // Pie chart placeholder
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value:
                                  metrics.activeShops /
                                  (metrics.totalShops > 0
                                      ? metrics.totalShops
                                      : 1),
                              strokeWidth: 12,
                              backgroundColor: AppColors.neutral300,
                              color: AppColors.success,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${metrics.activeShops}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Active',
                                style: TextStyle(
                                  color: AppColors.neutral600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Stats list
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _StatRow(
                        label: 'Total Users',
                        value: metrics.totalUsers.toString(),
                        color: AppColors.primary,
                      ),
                      _StatRow(
                        label: 'Total Shops',
                        value: metrics.totalShops.toString(),
                        color: AppColors.secondary,
                      ),
                      _StatRow(
                        label: 'Active Shops',
                        value: metrics.activeShops.toString(),
                        color: AppColors.success,
                      ),
                      _StatRow(
                        label: 'Pending Verifications',
                        value: metrics.pendingVerifications.toString(),
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthSection(PlatformMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: AppColors.info),
                const SizedBox(width: 8),
                const Text(
                  'Growth Metrics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24),

            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2,
              children: [
                _GrowthCard(
                  label: 'Products Listed',
                  value: metrics.totalProducts,
                  icon: Icons.inventory,
                ),
                _GrowthCard(
                  label: 'Transactions',
                  value: metrics.totalTransactions,
                  icon: Icons.receipt_long,
                ),
                _GrowthCard(
                  label: 'Active Consignments',
                  value: metrics.activeConsignments,
                  icon: Icons.handshake,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppColors.neutral600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _RevenueMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.neutral600, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.neutral600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _GrowthCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _GrowthCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neutral600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: AppColors.neutral600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
