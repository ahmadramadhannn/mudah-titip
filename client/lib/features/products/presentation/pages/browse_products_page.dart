import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/product.dart';
import '../bloc/product_bloc.dart';

/// Page for shop owners to browse available products from all consignors.
class BrowseProductsPage extends StatelessWidget {
  const BrowseProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProductBloc>()..add(const AvailableProductsLoadRequested()),
      child: const _BrowseProductsView(),
    );
  }
}

class _BrowseProductsView extends StatefulWidget {
  const _BrowseProductsView();

  @override
  State<_BrowseProductsView> createState() => _BrowseProductsViewState();
}

class _BrowseProductsViewState extends State<_BrowseProductsView> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Produk'),
        actions: [
          // Category filter
          PopupMenuButton<String?>(
            icon: Icon(
              _selectedCategory != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onSelected: (category) {
              setState(() => _selectedCategory = category);
              context.read<ProductBloc>().add(
                AvailableProductsLoadRequested(category: category),
              );
            },
            itemBuilder: (context) => [
              PopupMenuItem<String?>(
                value: null,
                child: Row(
                  children: [
                    Icon(
                      _selectedCategory == null
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Semua Kategori'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ..._buildCategoryMenuItems(),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductFailure) {
            return _buildErrorState(context, state.message);
          }

          if (state is ProductLoadSuccess) {
            final products = state.products;

            if (products.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(
                  AvailableProductsLoadRequested(category: _selectedCategory),
                );
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _ProductCard(
                    product: products[index],
                    onProposeAgreement: () =>
                        _onProposeAgreement(context, products[index]),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildCategoryMenuItems() {
    final categories = [
      'Makanan Ringan',
      'Kue Basah',
      'Kue Kering',
      'Frozen Food',
      'Lainnya',
    ];

    return categories.map((category) {
      return PopupMenuItem<String>(
        value: category,
        child: Row(
          children: [
            Icon(
              _selectedCategory == category
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(category),
          ],
        ),
      );
    }).toList();
  }

  void _onProposeAgreement(BuildContext context, Product product) {
    // Navigate to create consignment page with product ID
    context.push('/consignments/create/${product.id}');
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
              Icons.inventory_2_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Produk',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada produk tersedia untuk kategori ini.',
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
                context.read<ProductBloc>().add(
                  AvailableProductsLoadRequested(category: _selectedCategory),
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

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onProposeAgreement;

  const _ProductCard({required this.product, required this.onProposeAgreement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Show product details bottom sheet
          _showProductDetails(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            AspectRatio(
              aspectRatio: 1,
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.inventory_2,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.inventory_2,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                    ),
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${product.basePrice.toStringAsFixed(0)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Propose Agreement Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: onProposeAgreement,
                        icon: const Icon(Icons.handshake, size: 18),
                        label: const Text(
                          'Ajukan',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
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

  void _showProductDetails(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Product Image
              if (product.imageUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (product.imageUrl != null) const SizedBox(height: 24),
              // Product Name
              Text(
                product.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Price
              Text(
                'Rp ${product.basePrice.toStringAsFixed(0)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // Description
              if (product.description != null) ...[
                Text(
                  'Deskripsi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(product.description!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
              ],
              // Category
              _DetailRow(label: 'Kategori', value: product.category ?? '-'),
              const SizedBox(height: 8),
              // Shelf Life
              if (product.shelfLifeDays != null)
                _DetailRow(
                  label: 'Masa Simpan',
                  value: '${product.shelfLifeDays} hari',
                ),
              const SizedBox(height: 24),
              // Propose Agreement Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onProposeAgreement();
                  },
                  icon: const Icon(Icons.handshake),
                  label: const Text('Ajukan Perjanjian'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
