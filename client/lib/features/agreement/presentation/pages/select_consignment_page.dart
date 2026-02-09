import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../consignment/data/models/consignment.dart';
import '../../../consignment/presentation/bloc/consignment_bloc.dart';

/// Page for selecting a consignment to propose an agreement for.
class SelectConsignmentPage extends StatelessWidget {
  const SelectConsignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ConsignmentBloc>()
            ..add(const LoadConsignmentsWithoutAgreement()),
      child: const _SelectConsignmentView(),
    );
  }
}

class _SelectConsignmentView extends StatelessWidget {
  const _SelectConsignmentView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectConsignment)),
      body: BlocBuilder<ConsignmentBloc, ConsignmentState>(
        builder: (context, state) {
          if (state is ConsignmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConsignmentError) {
            return _buildErrorState(context, state.message);
          }

          if (state is ConsignmentsLoaded) {
            final consignments = state.consignments;

            if (consignments.isEmpty) {
              return _buildEmptyState(context, l10n);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ConsignmentBloc>().add(
                  const LoadConsignmentsWithoutAgreement(),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: consignments.length,
                itemBuilder: (context, index) {
                  return _ConsignmentCard(
                    consignment: consignments[index],
                    onTap: () =>
                        _onSelectConsignment(context, consignments[index]),
                  );
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _onSelectConsignment(BuildContext context, Consignment consignment) {
    context.push('/agreements/propose/${consignment.id}');
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Titipan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua titipan Anda sudah memiliki perjanjian aktif, atau Anda belum memiliki titipan.',
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
    final l10n = AppLocalizations.of(context)!;

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
                context.read<ConsignmentBloc>().add(
                  const LoadConsignmentsWithoutAgreement(),
                );
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsignmentCard extends StatelessWidget {
  final Consignment consignment;
  final VoidCallback onTap;

  const _ConsignmentCard({required this.consignment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: consignment.product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          consignment.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.inventory_2,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      )
                    : Icon(Icons.inventory_2, color: theme.colorScheme.outline),
              ),
              const SizedBox(width: 16),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consignment.product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          consignment.shop.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${consignment.currentQuantity} pcs',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
