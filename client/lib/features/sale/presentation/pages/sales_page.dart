import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/sale.dart';
import '../bloc/sale_bloc.dart';

/// Page displaying list of sales with summary header.
class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SaleBloc(getIt())..add(const LoadMySales()),
      child: const _SalesView(),
    );
  }
}

class _SalesView extends StatefulWidget {
  const _SalesView();

  @override
  State<_SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<_SalesView> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
  }

  void _loadSales() {
    context.read<SaleBloc>().add(
      LoadMySales(startDate: _startDate, endDate: _endDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sales),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showDateFilter(context),
          ),
        ],
      ),
      body: BlocBuilder<SaleBloc, SaleState>(
        builder: (context, state) {
          if (state is SaleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SaleError) {
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
                  ElevatedButton(
                    onPressed: _loadSales,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is SalesLoaded) {
            return RefreshIndicator(
              onRefresh: () async => _loadSales(),
              child: CustomScrollView(
                slivers: [
                  // Summary Header
                  SliverToBoxAdapter(
                    child: _SummaryCard(
                      summary: state.summary,
                      currencyFormat: currencyFormat,
                    ),
                  ),

                  // Sales List
                  if (state.sales.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState(context))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _SaleCard(
                            sale: state.sales[index],
                            currencyFormat: currencyFormat,
                          ),
                          childCount: state.sales.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sales/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.recordSale),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(l10n.noSales, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.noData,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _showDateFilter(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.filter, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.thisWeek),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _endDate = DateTime.now();
                  _startDate = _endDate!.subtract(const Duration(days: 7));
                });
                _loadSales();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(l10n.thisMonth),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _endDate = DateTime.now();
                  _startDate = _endDate!.subtract(const Duration(days: 30));
                });
                _loadSales();
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text('3 ${l10n.thisMonth}'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _endDate = DateTime.now();
                  _startDate = _endDate!.subtract(const Duration(days: 90));
                });
                _loadSales();
              },
            ),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(l10n.all),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
                _loadSales();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final SalesSummary summary;
  final NumberFormat currencyFormat;

  const _SummaryCard({required this.summary, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM', 'id');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.summary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${dateFormat.format(summary.startDate)} - ${dateFormat.format(summary.endDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: l10n.totalEarnings,
                    value: currencyFormat.format(summary.totalEarnings),
                    icon: Icons.monetization_on,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: l10n.totalSales,
                    value: '${summary.totalSales}',
                    icon: Icons.receipt,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: l10n.soldItems,
                    value: '${summary.totalItemsSold}',
                    icon: Icons.shopping_bag,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  final NumberFormat currencyFormat;

  const _SaleCard({required this.sale, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Row(
              children: [
                Expanded(
                  child: Text(
                    sale.consignment.product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  currencyFormat.format(sale.totalAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Shop and date
            Row(
              children: [
                Icon(Icons.store, size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  sale.consignment.shop.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(sale.soldAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Commission breakdown
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip(
                    label: l10n.quantity,
                    value: '${sale.quantitySold}',
                  ),
                  _InfoChip(
                    label: l10n.shopCommission,
                    value: currencyFormat.format(sale.shopCommission),
                  ),
                  _InfoChip(
                    label: l10n.earnings,
                    value: currencyFormat.format(sale.consignorEarning),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
