import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/consignment.dart';
import '../bloc/consignment_bloc.dart';

/// Page displaying consignment details.
class ConsignmentDetailPage extends StatelessWidget {
  final int consignmentId;

  const ConsignmentDetailPage({super.key, required this.consignmentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ConsignmentBloc(getIt())..add(LoadConsignmentDetail(consignmentId)),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Titipan')),
      body: BlocConsumer<ConsignmentBloc, ConsignmentState>(
        listener: (context, state) {
          if (state is ConsignmentStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Status berhasil diubah ke ${state.consignment.status.displayName}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ConsignmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConsignmentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          if (state is ConsignmentDetailLoaded ||
              state is ConsignmentStatusUpdated) {
            final consignment = state is ConsignmentDetailLoaded
                ? state.consignment
                : (state as ConsignmentStatusUpdated).consignment;
            return _buildContent(context, consignment);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Consignment consignment) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMMM yyyy', 'id');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: consignment.product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              consignment.product.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.inventory_2,
                            color: theme.colorScheme.outline,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consignment.product.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          consignment.product.category ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: consignment.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Shop Info
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.store)),
              title: Text(consignment.shop.name),
              subtitle: consignment.shop.address != null
                  ? Text(consignment.shop.address!)
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Grid
          Text('Statistik', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2,
            children: [
              _StatCard(
                label: 'Stok Tersisa',
                value: '${consignment.currentQuantity}',
                icon: Icons.inventory,
                color: Colors.blue,
              ),
              _StatCard(
                label: 'Terjual',
                value: '${consignment.soldQuantity}',
                icon: Icons.shopping_cart,
                color: Colors.green,
              ),
              _StatCard(
                label: 'Harga Jual',
                value: currencyFormat.format(consignment.sellingPrice),
                icon: Icons.sell,
                color: Colors.orange,
              ),
              _StatCard(
                label: 'Komisi Toko',
                value: '${consignment.commissionPercent.toStringAsFixed(0)}%',
                icon: Icons.percent,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dates
          Text('Tanggal', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Tanggal Titip'),
                  trailing: Text(
                    consignment.consignmentDate != null
                        ? dateFormat.format(consignment.consignmentDate!)
                        : '-',
                  ),
                ),
                if (consignment.expiryDate != null)
                  ListTile(
                    leading: Icon(
                      Icons.event_busy,
                      color: consignment.isExpired
                          ? theme.colorScheme.error
                          : null,
                    ),
                    title: const Text('Tanggal Kadaluarsa'),
                    trailing: Text(
                      dateFormat.format(consignment.expiryDate!),
                      style: TextStyle(
                        color: consignment.isExpired
                            ? theme.colorScheme.error
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          if (consignment.notes != null && consignment.notes!.isNotEmpty) ...[
            Text('Catatan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(consignment.notes!),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Actions
          if (consignment.status == ConsignmentStatus.active) ...[
            Text('Ubah Status', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmStatusChange(
                      context,
                      consignment,
                      ConsignmentStatus.completed,
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Selesai'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmStatusChange(
                      context,
                      consignment,
                      ConsignmentStatus.returned,
                    ),
                    icon: const Icon(Icons.undo),
                    label: const Text('Kembalikan'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmStatusChange(
    BuildContext context,
    Consignment consignment,
    ConsignmentStatus newStatus,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(
          'Ubah status titipan ini menjadi "${newStatus.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ConsignmentBloc>().add(
                UpdateConsignmentStatus(
                  consignmentId: consignment.id,
                  status: newStatus,
                ),
              );
            },
            child: const Text('Ya, Ubah'),
          ),
        ],
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelSmall),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
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
