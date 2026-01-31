import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/guest_consignor.dart';
import '../../data/repositories/guest_consignor_repository.dart';
import '../bloc/guest_consignor_bloc.dart';

/// Page showing guest consignor details with products and summary.
class GuestConsignorDetailPage extends StatefulWidget {
  final int guestConsignorId;

  const GuestConsignorDetailPage({super.key, required this.guestConsignorId});

  @override
  State<GuestConsignorDetailPage> createState() =>
      _GuestConsignorDetailPageState();
}

class _GuestConsignorDetailPageState extends State<GuestConsignorDetailPage> {
  GuestConsignor? _guestConsignor;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGuestConsignor();
  }

  Future<void> _loadGuestConsignor() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = getIt<GuestConsignorRepository>();
      final guest = await repository.getById(widget.guestConsignorId);
      setState(() {
        _guestConsignor = guest;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data penitip: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GuestConsignorBloc(getIt<GuestConsignorRepository>()),
      child: BlocListener<GuestConsignorBloc, GuestConsignorState>(
        listener: (context, state) {
          if (state is GuestConsignorOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Go back to list after deletion
            context.pop();
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
        child: Scaffold(
          appBar: AppBar(
            title: Text(_guestConsignor?.name ?? 'Detail Penitip'),
            actions: [
              if (_guestConsignor != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editGuestConsignor();
                    } else if (value == 'delete') {
                      _confirmDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hapus',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: _buildBody(),
          floatingActionButton: _guestConsignor != null
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // Navigate to add product for this guest consignor
                    context.push(
                      '/guest-consignors/${widget.guestConsignorId}/products/add',
                    );
                  },
                  icon: const Icon(Icons.add_box),
                  label: const Text('Tambah Produk'),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGuestConsignor,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_guestConsignor == null) {
      return const Center(child: Text('Penitip tidak ditemukan'));
    }

    return RefreshIndicator(
      onRefresh: _loadGuestConsignor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            _buildProfileCard(),
            const SizedBox(height: 24),

            // Quick actions
            Text('Aksi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Info card
            Text('Informasi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildInfoCard(),

            // Placeholder for products section (to be implemented)
            const SizedBox(height: 24),
            Text('Produk', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildProductsPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final guest = _guestConsignor!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            child: Text(
              guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      guest.phone,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.add_box_outlined,
            label: 'Tambah\nProduk',
            onTap: () {
              context.push(
                '/guest-consignors/${widget.guestConsignorId}/products/add',
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.local_shipping_outlined,
            label: 'Lihat\nTitipan',
            onTap: () {
              // TODO: Navigate to consignments filtered by this guest
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur akan segera hadir')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Laporan\nPenjualan',
            onTap: () {
              // TODO: Show sales report for this guest
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur akan segera hadir')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final guest = _guestConsignor!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Telepon',
              value: guest.phone,
            ),
            if (guest.address != null && guest.address!.isNotEmpty) ...[
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Alamat',
                value: guest.address!,
              ),
            ],
            if (guest.notes != null && guest.notes!.isNotEmpty) ...[
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.note_outlined,
                label: 'Catatan',
                value: guest.notes!,
              ),
            ],
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Terdaftar',
              value: _formatDate(guest.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsPlaceholder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'Produk akan ditampilkan di sini',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                context.push(
                  '/guest-consignors/${widget.guestConsignorId}/products/add',
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Produk Pertama'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editGuestConsignor() {
    context.push('/guest-consignors/${widget.guestConsignorId}/edit');
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Penitip?'),
        content: Text(
          'Anda yakin ingin menghapus ${_guestConsignor?.name}? '
          'Data produk dan titipan yang terkait mungkin terpengaruh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GuestConsignorBloc>().add(
                GuestConsignorDeleteRequested(id: widget.guestConsignorId),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.neutral500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.neutral500),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
