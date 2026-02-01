import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/analytics_models.dart';
import '../bloc/analytics_bloc.dart';

/// Analytics dashboard page with charts.
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return BlocProvider(
      create: (_) => AnalyticsBloc(getIt())
        ..add(
          LoadAnalytics(
            startDate: now.subtract(const Duration(days: 30)),
            endDate: now,
          ),
        ),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView();

  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> {
  int _selectedDays = 30;

  void _loadData() {
    final now = DateTime.now();
    context.read<AnalyticsBloc>().add(
      LoadAnalytics(
        startDate: now.subtract(Duration(days: _selectedDays)),
        endDate: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (days) {
              setState(() => _selectedDays = days);
              _loadData();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 7, child: Text('7 ${l10n.thisWeek}')),
              PopupMenuItem(value: 14, child: Text('14 ${l10n.thisWeek}')),
              PopupMenuItem(value: 30, child: Text('30 ${l10n.thisMonth}')),
              PopupMenuItem(value: 90, child: Text('90 ${l10n.thisMonth}')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnalyticsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: Text(l10n.retry)),
                ],
              ),
            );
          }

          if (state is AnalyticsLoaded) {
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Period indicator
                  Text(
                    '$_selectedDays ${l10n.thisWeek}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sales Trend Chart
                  _SectionTitle(
                    title: l10n.salesTrend,
                    icon: Icons.trending_up,
                  ),
                  const SizedBox(height: 8),
                  _TrendChart(trends: state.trends),
                  const SizedBox(height: 24),

                  // Top Products Chart
                  _SectionTitle(title: l10n.topProducts, icon: Icons.star),
                  const SizedBox(height: 8),
                  _TopProductsChart(products: state.topProducts),
                  const SizedBox(height: 24),

                  // Earnings Breakdown
                  _SectionTitle(
                    title: l10n.earningsBreakdown,
                    icon: Icons.pie_chart,
                  ),
                  const SizedBox(height: 8),
                  _BreakdownChart(breakdown: state.breakdown),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Line chart showing earnings trend over time.
class _TrendChart extends StatelessWidget {
  final List<TrendData> trends;

  const _TrendChart({required this.trends});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (trends.isEmpty || trends.every((t) => t.earnings == 0)) {
      return _EmptyChart(message: l10n.noAnalyticsData);
    }

    final maxY = trends.map((t) => t.earnings).reduce((a, b) => a > b ? a : b);
    final spots = trends.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.earnings);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatCurrency(value),
                        style: theme.textTheme.labelSmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: trends.length > 7
                        ? (trends.length / 5).ceil().toDouble()
                        : 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= trends.length)
                        return const SizedBox();
                      return Text(
                        DateFormat('d/M').format(trends[idx].date),
                        style: theme.textTheme.labelSmall,
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final trend = trends[spot.x.toInt()];
                      return LineTooltipItem(
                        '${DateFormat('d MMM').format(trend.date)}\n${_formatCurrencyFull(trend.earnings)}',
                        TextStyle(color: theme.colorScheme.onPrimary),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bar chart showing top products.
class _TopProductsChart extends StatelessWidget {
  final List<TopProduct> products;

  const _TopProductsChart({required this.products});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (products.isEmpty) {
      return _EmptyChart(message: l10n.noAnalyticsData);
    }

    final maxY = products
        .map((p) => p.totalEarnings)
        .reduce((a, b) => a > b ? a : b);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.2,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= products.length)
                            return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _truncate(products[idx].productName, 10),
                              style: theme.textTheme.labelSmall,
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: products.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.totalEarnings,
                          color: colors[entry.key % colors.length],
                          width: 24,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final product = products[groupIndex];
                        return BarTooltipItem(
                          '${product.productName}\n${currencyFormat.format(product.totalEarnings)}',
                          TextStyle(color: theme.colorScheme.onPrimary),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: products.asMap().entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[entry.key % colors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.value.productName} (${entry.value.totalSold} ${l10n.units})',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pie chart showing earnings breakdown.
class _BreakdownChart extends StatelessWidget {
  final List<EarningsBreakdown> breakdown;

  const _BreakdownChart({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (breakdown.isEmpty) {
      return _EmptyChart(message: l10n.noAnalyticsData);
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: breakdown.asMap().entries.map((entry) {
                    final item = entry.value;
                    return PieChartSectionData(
                      value: item.percentage,
                      title: '${item.percentage.toStringAsFixed(0)}%',
                      color: colors[entry.key % colors.length],
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            ...breakdown.asMap().entries.map((entry) {
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[entry.key % colors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.productName)),
                    Text(
                      currencyFormat.format(item.earnings),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 150,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCurrency(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}jt';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}rb';
  }
  return value.toStringAsFixed(0);
}

String _formatCurrencyFull(double value) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(value);
}

String _truncate(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}
