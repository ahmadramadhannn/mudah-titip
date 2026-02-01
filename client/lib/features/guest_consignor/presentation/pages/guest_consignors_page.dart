import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/guest_consignor.dart';
import '../../data/repositories/guest_consignor_repository.dart';
import '../bloc/guest_consignor_bloc.dart';

/// Page displaying list of guest consignors for shop owner.
class GuestConsignorsPage extends StatelessWidget {
  const GuestConsignorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GuestConsignorBloc(getIt<GuestConsignorRepository>())
            ..add(const GuestConsignorLoadRequested()),
      child: const _GuestConsignorsContent(),
    );
  }
}

class _GuestConsignorsContent extends StatelessWidget {
  const _GuestConsignorsContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.guestConsignors),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<GuestConsignorBloc, GuestConsignorState>(
        listener: (context, state) {
          if (state is GuestConsignorOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload list after successful operation
            context.read<GuestConsignorBloc>().add(
              const GuestConsignorLoadRequested(),
            );
          }
          if (state is GuestConsignorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GuestConsignorLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GuestConsignorLoaded) {
            if (state.guestConsignors.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildList(context, state.guestConsignors);
          }

          if (state is GuestConsignorError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<GuestConsignorBloc>().add(
                      const GuestConsignorLoadRequested(),
                    ),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/guest-consignors/add'),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addGuestConsignor),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.neutral400),
          const SizedBox(height: 16),
          Text(
            l10n.noGuestConsignors,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noData,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/guest-consignors/add'),
            icon: const Icon(Icons.person_add),
            label: Text(l10n.addGuestConsignor),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<GuestConsignor> guestConsignors,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GuestConsignorBloc>().add(
          const GuestConsignorLoadRequested(),
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guestConsignors.length,
        itemBuilder: (context, index) {
          final guest = guestConsignors[index];
          return _GuestConsignorCard(guest: guest);
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.search),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: '${l10n.name} / ${l10n.phone}',
            prefixIcon: const Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final query = searchController.text.trim();
              if (query.isNotEmpty) {
                // Check if it's a phone number (starts with digit or +)
                final isPhone = RegExp(r'^[\d+]').hasMatch(query);
                context.read<GuestConsignorBloc>().add(
                  GuestConsignorSearchRequested(
                    phone: isPhone ? query : null,
                    name: isPhone ? null : query,
                  ),
                );
              }
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.search),
          ),
        ],
      ),
    );
  }
}

class _GuestConsignorCard extends StatelessWidget {
  final GuestConsignor guest;

  const _GuestConsignorCard({required this.guest});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/guest-consignors/${guest.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guest.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.neutral500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          guest.phone,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                    if (guest.address != null && guest.address!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              guest.address!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.neutral500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}
