import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/agreement.dart';
import '../../data/models/agreement_status.dart';
import '../bloc/agreement_bloc.dart';

/// Page displaying pending agreements for the current user.
class AgreementsPage extends StatelessWidget {
  const AgreementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AgreementBloc>()..add(const LoadPendingAgreements()),
      child: const _AgreementsView(),
    );
  }
}

class _AgreementsView extends StatelessWidget {
  const _AgreementsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perjanjian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AgreementBloc>().add(const LoadPendingAgreements());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProposeDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajukan'),
      ),
      body: BlocConsumer<AgreementBloc, AgreementState>(
        listener: (context, state) {
          if (state is AgreementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AgreementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AgreementsLoaded) {
            final agreements = state.agreements;

            if (agreements.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AgreementBloc>().add(
                  const LoadPendingAgreements(),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: agreements.length,
                itemBuilder: (context, index) {
                  return _AgreementCard(agreement: agreements[index]);
                },
              ),
            );
          }

          if (state is AgreementError) {
            return _buildErrorState(context, state.message);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showProposeDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajukan Perjanjian Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan ID konsinyasi untuk mengajukan perjanjian:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'ID Konsinyasi',
                hintText: 'Contoh: 1',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              final id = int.tryParse(controller.text);
              if (id != null) {
                Navigator.pop(dialogContext);
                context.push('/agreements/propose/$id');
              }
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Perjanjian',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda tidak memiliki perjanjian yang perlu ditanggapi saat ini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                context.read<AgreementBloc>().add(
                  const LoadPendingAgreements(),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgreementCard extends StatelessWidget {
  final Agreement agreement;

  const _AgreementCard({required this.agreement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/agreements/${agreement.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      agreement.consignment.product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: agreement.status),
                ],
              ),
              const SizedBox(height: 8),

              // Shop name
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    agreement.consignment.shop.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Commission info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.percent,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        agreement.commissionDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Proposed by
              const SizedBox(height: 8),
              Text(
                'Diajukan oleh ${agreement.proposedBy.name}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),

              // Terms note if available
              if (agreement.termsNote != null &&
                  agreement.termsNote!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  agreement.termsNote!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
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
