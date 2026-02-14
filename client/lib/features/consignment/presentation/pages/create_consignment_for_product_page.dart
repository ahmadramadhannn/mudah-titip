import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../products/data/models/product.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../../core/widgets/quantity_selector.dart';
import '../../data/consignment_repository.dart';
import '../../data/models/consignment_request.dart';
import '../bloc/consignment_bloc.dart';

/// Page for shop owners to create a consignment for a specific product.
/// After creation, navigates to propose agreement page.
class CreateConsignmentForProductPage extends StatelessWidget {
  final int productId;

  const CreateConsignmentForProductPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConsignmentBloc>(),
      child: _CreateConsignmentForm(productId: productId),
    );
  }
}

class _CreateConsignmentForm extends StatefulWidget {
  final int productId;

  const _CreateConsignmentForm({required this.productId});

  @override
  State<_CreateConsignmentForm> createState() => _CreateConsignmentFormState();
}

class _CreateConsignmentFormState extends State<_CreateConsignmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _notesController = TextEditingController();

  Product? _product;
  bool _isLoadingProduct = false;
  String? _productError;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _sellingPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoadingProduct = true;
      _productError = null;
    });

    try {
      final productRepo = getIt<ProductRepository>();
      final product = await productRepo.getProduct(widget.productId);
      setState(() {
        _product = product;
        // Pre-fill selling price with base price
        _sellingPriceController.text = product.basePrice.toStringAsFixed(0);
        _isLoadingProduct = false;
      });
    } catch (e) {
      setState(() {
        _productError = e.toString();
        _isLoadingProduct = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_product == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product not loaded')));
      return;
    }

    try {
      print('DEBUG: Starting consignment creation...');
      final consignmentRepo = getIt<ConsignmentRepository>();

      // Create consignment request (commissionPercent defaults to 0)
      final request = ConsignmentRequest(
        productId: widget.productId,
        shopId: 0, // Will be set by backend from authenticated user
        quantity: int.parse(_quantityController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      print('DEBUG: Request data: ${request.toJson()}');

      // Create consignment
      print('DEBUG: Calling API...');
      final consignment = await consignmentRepo.createConsignment(request);

      print('DEBUG: Consignment created with ID: ${consignment.id}');

      if (!mounted) return;

      // Navigate to propose agreement page
      print('DEBUG: Navigating to /agreements/propose/${consignment.id}');
      context.go('/agreements/propose/${consignment.id}');
    } catch (e, stackTrace) {
      print('DEBUG: Error occurred!');
      print('DEBUG: Error: $e');
      print('DEBUG: StackTrace: $stackTrace');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoadingProduct) {
      return Scaffold(
        appBar: AppBar(title: const Text('Buat Titipan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_productError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Buat Titipan')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Failed to load product'),
              const SizedBox(height: 8),
              Text(_productError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _loadProduct, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Buat Titipan')),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Titipan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produk',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Product Image
                        if (_product!.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _product!.imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.inventory_2,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                          ),
                        if (_product!.imageUrl != null)
                          const SizedBox(width: 16),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _product!.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Harga Dasar: Rp ${_product!.basePrice.toStringAsFixed(0)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              if (_product!.category != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _product!.category!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quantity Field
            QuantitySelector(
              controller: _quantityController,
              label: 'Jumlah *',
              suffixText: 'pcs',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah harus diisi';
                }
                final qty = int.tryParse(value);
                if (qty == null || qty <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Selling Price Field
            TextFormField(
              controller: _sellingPriceController,
              decoration: const InputDecoration(
                labelText: 'Harga Jual *',
                hintText: 'Masukkan harga jual',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga jual harus diisi';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Harga harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Notes Field
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Tambahkan catatan jika diperlukan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            // Info Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Setelah membuat titipan, Anda akan diminta untuk mengajukan perjanjian dengan penitip.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Submit Button
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Lanjutkan ke Perjanjian'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
