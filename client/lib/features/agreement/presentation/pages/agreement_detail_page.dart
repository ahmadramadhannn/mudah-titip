import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/agreement.dart';
import '../../data/models/agreement_status.dart';
import '../../data/models/commission_type.dart';
import '../bloc/agreement_bloc.dart';

/// Page for viewing agreement details and responding to proposals.
class AgreementDetailPage extends StatefulWidget {
  final int agreementId;
  final Agreement? agreement;

  const AgreementDetailPage({
    super.key,
    required this.agreementId,
    this.agreement,
  });

  @override
  State<AgreementDetailPage> createState() => _AgreementDetailPageState();
}

class _AgreementDetailPageState extends State<AgreementDetailPage> {
  late Agreement? _agreement;

  @override
  void initState() {
    super.initState();
    _agreement = widget.agreement;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AgreementBloc>(),
      child: _AgreementDetailView(
        agreement: _agreement,
        onAgreementUpdated: (agreement) {
          setState(() => _agreement = agreement);
        },
      ),
    );
  }
}

class _AgreementDetailView extends StatelessWidget {
  final Agreement? agreement;
  final ValueChanged<Agreement> onAgreementUpdated;

  const _AgreementDetailView({
    required this.agreement,
    required this.onAgreementUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (agreement == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Perjanjian')),
        body: const Center(child: Text('Perjanjian tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Perjanjian')),
      body: BlocListener<AgreementBloc, AgreementState>(
        listener: (context, state) {
          if (state is AgreementActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            onAgreementUpdated(state.agreement);
            // Pop back if accepted or rejected
            if (state.agreement.status == AgreementStatus.accepted ||
                state.agreement.status == AgreementStatus.rejected) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) context.pop(true);
              });
            }
          } else if (state is AgreementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Info Card
              _buildProductCard(context, agreement!),
              const SizedBox(height: 16),

              // Agreement Details Card
              _buildAgreementCard(context, agreement!),
              const SizedBox(height: 16),

              // Terms Note if available
              if (agreement!.termsNote != null &&
                  agreement!.termsNote!.isNotEmpty) ...[
                _buildTermsCard(context, agreement!),
                const SizedBox(height: 16),
              ],

              // Action Buttons (only if pending)
              if (agreement!.isPending) ...[
                _buildActionButtons(context, agreement!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Agreement agreement) {
    final theme = Theme.of(context);
    final consignment = agreement.consignment;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Produk',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              consignment.product.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.store,
              label: 'Toko',
              value: consignment.shop.name,
            ),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.inventory,
              label: 'Jumlah',
              value:
                  '${consignment.currentQuantity}/${consignment.initialQuantity} unit',
            ),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.sell,
              label: 'Harga Jual',
              value: 'Rp${consignment.sellingPrice.toStringAsFixed(0)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreementCard(BuildContext context, Agreement agreement) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.handshake_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detail Perjanjian',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _StatusBadge(status: agreement.status),
              ],
            ),
            const Divider(height: 24),

            // Commission Type
            _InfoRow(
              icon: Icons.category,
              label: 'Tipe Komisi',
              value: agreement.commissionType.displayName,
            ),
            const SizedBox(height: 8),

            // Commission Value based on type
            _buildCommissionValue(context, agreement),
            const SizedBox(height: 8),

            // Proposed By
            _InfoRow(
              icon: Icons.person,
              label: 'Diajukan oleh',
              value: agreement.proposedBy.name,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionValue(BuildContext context, Agreement agreement) {
    switch (agreement.commissionType) {
      case CommissionType.percentage:
        return _InfoRow(
          icon: Icons.percent,
          label: 'Persentase',
          value: '${agreement.commissionValue?.toStringAsFixed(0) ?? 0}%',
        );

      case CommissionType.fixedPerItem:
        return _InfoRow(
          icon: Icons.monetization_on,
          label: 'Per Item',
          value: 'Rp${agreement.commissionValue?.toStringAsFixed(0) ?? 0}',
        );

      case CommissionType.tieredBonus:
        return Column(
          children: [
            _InfoRow(
              icon: Icons.trending_up,
              label: 'Target',
              value: '${agreement.bonusThresholdPercent ?? 0}% terjual',
            ),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.card_giftcard,
              label: 'Bonus',
              value: 'Rp${agreement.bonusAmount?.toStringAsFixed(0) ?? 0}',
            ),
          ],
        );
    }
  }

  Widget _buildTermsCard(BuildContext context, Agreement agreement) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_alt_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Catatan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(agreement.termsNote!, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Agreement agreement) {
    return BlocBuilder<AgreementBloc, AgreementState>(
      builder: (context, state) {
        final isLoading = state is AgreementActionInProgress;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accept Button
            FilledButton.icon(
              onPressed: isLoading
                  ? null
                  : () => _showAcceptDialog(context, agreement),
              icon: const Icon(Icons.check),
              label: const Text('Setujui'),
            ),
            const SizedBox(height: 8),

            // Counter Button
            OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      context.push(
                        '/agreements/propose/${agreement.consignment.id}',
                      );
                    },
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Ajukan Penawaran Balik'),
            ),
            const SizedBox(height: 8),

            // Reject Button
            TextButton.icon(
              onPressed: isLoading
                  ? null
                  : () => _showRejectDialog(context, agreement),
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.error,
              ),
              label: Text(
                'Tolak',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAcceptDialog(BuildContext context, Agreement agreement) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Setujui Perjanjian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin menyetujui perjanjian ini?'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Pesan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AgreementBloc>().add(
                AcceptAgreement(
                  agreementId: agreement.id,
                  message: messageController.text.isNotEmpty
                      ? messageController.text
                      : null,
                ),
              );
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, Agreement agreement) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tolak Perjanjian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin menolak perjanjian ini?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan penolakan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AgreementBloc>().add(
                RejectAgreement(
                  agreementId: agreement.id,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : null,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.outline),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AgreementStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = _getColors(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _getColors(BuildContext context) {
    return switch (status) {
      AgreementStatus.proposed => (
        Colors.orange.shade700,
        Colors.orange.shade50,
      ),
      AgreementStatus.counter => (Colors.blue.shade700, Colors.blue.shade50),
      AgreementStatus.accepted => (Colors.green.shade700, Colors.green.shade50),
      AgreementStatus.rejected => (Colors.red.shade700, Colors.red.shade50),
    };
  }
}
