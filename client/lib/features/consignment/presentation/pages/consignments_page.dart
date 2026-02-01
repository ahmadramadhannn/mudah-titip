import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/consignment.dart';
import '../bloc/consignment_bloc.dart';

/// Page displaying list of user's consignments with filter tabs.
class ConsignmentsPage extends StatelessWidget {
  const ConsignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConsignmentBloc(getIt())..add(const LoadConsignments()),
      child: const _ConsignmentsView(),
    );
  }
}

class _ConsignmentsView extends StatefulWidget {
  const _ConsignmentsView();

  @override
  State<_ConsignmentsView> createState() => _ConsignmentsViewState();
}

class _ConsignmentsViewState extends State<_ConsignmentsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = [null, ...ConsignmentStatus.values];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final status = _tabs[_tabController.index];
      context.read<ConsignmentBloc>().add(LoadConsignments(status: status));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.consignments),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.all),
            ...ConsignmentStatus.values.map((s) => Tab(text: s.displayName)),
          ],
        ),
      ),
      body: BlocBuilder<ConsignmentBloc, ConsignmentState>(
        builder: (context, state) {
          if (state is ConsignmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConsignmentError) {
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
                    onPressed: () => context.read<ConsignmentBloc>().add(
                      LoadConsignments(status: _tabs[_tabController.index]),
                    ),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is ConsignmentsLoaded) {
            if (state.consignments.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ConsignmentBloc>().add(
                  LoadConsignments(status: state.filterStatus),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.consignments.length,
                itemBuilder: (context, index) {
                  return _ConsignmentCard(
                    consignment: state.consignments[index],
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/consignments/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addConsignment),
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
            Icons.inventory_2_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noConsignments,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFirstProduct,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/consignments/add'),
            icon: const Icon(Icons.add),
            label: Text(l10n.addConsignment),
          ),
        ],
      ),
    );
  }
}

class _ConsignmentCard extends StatelessWidget {
  final Consignment consignment;

  const _ConsignmentCard({required this.consignment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/consignments/${consignment.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Product name & status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      consignment.product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusChip(status: consignment.status),
                ],
              ),
              const SizedBox(height: 8),

              // Shop info
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    consignment.shop.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quantity & price info
              Row(
                children: [
                  _InfoItem(
                    label: l10n.quantity,
                    value:
                        '${consignment.currentQuantity}/${consignment.initialQuantity}',
                    icon: Icons.inventory,
                  ),
                  const SizedBox(width: 24),
                  _InfoItem(
                    label: l10n.price,
                    value: currencyFormat.format(consignment.sellingPrice),
                    icon: Icons.sell,
                  ),
                  const SizedBox(width: 24),
                  _InfoItem(
                    label: l10n.commission,
                    value:
                        '${consignment.commissionPercent.toStringAsFixed(0)}%',
                    icon: Icons.percent,
                  ),
                ],
              ),

              // Expiry warning if applicable
              if (consignment.expiryDate != null &&
                  consignment.isExpiringWithin(7))
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 16,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${l10n.expiryDate}: ${DateFormat('dd MMM yyyy', 'id').format(consignment.expiryDate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ConsignmentStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = switch (status) {
      ConsignmentStatus.active => (Colors.green.shade700, Colors.green.shade50),
      ConsignmentStatus.completed => (
        Colors.blue.shade700,
        Colors.blue.shade50,
      ),
      ConsignmentStatus.expired => (Colors.red.shade700, Colors.red.shade50),
      ConsignmentStatus.returned => (
        Colors.orange.shade700,
        Colors.orange.shade50,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: theme.colorScheme.outline),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
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
