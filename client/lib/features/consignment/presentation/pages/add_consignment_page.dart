import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../products/data/models/product.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../data/models/consignment_request.dart';
import '../bloc/consignment_bloc.dart';

/// Page for creating a new consignment.
class AddConsignmentPage extends StatelessWidget {
  const AddConsignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConsignmentBloc(getIt()),
      child: const _AddConsignmentForm(),
    );
  }
}

class _AddConsignmentForm extends StatefulWidget {
  const _AddConsignmentForm();

  @override
  State<_AddConsignmentForm> createState() => _AddConsignmentFormState();
}

class _AddConsignmentFormState extends State<_AddConsignmentForm> {
  final _formKey = GlobalKey<FormState>();

  Product? _selectedProduct;
  final _quantityController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _commissionController = TextEditingController(text: '10');
  final _notesController = TextEditingController();
  DateTime? _consignmentDate;
  DateTime? _expiryDate;

  List<Product> _products = [];
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _consignmentDate = DateTime.now();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _sellingPriceController.dispose();
    _commissionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final repo = getIt<ProductRepository>();
      final products = await repo.getMyProducts();
      setState(() {
        _products = products;
        _loadingProducts = false;
      });
    } catch (e) {
      setState(() => _loadingProducts = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu')),
      );
      return;
    }

    // TODO: Add shop selection - for now use a hardcoded shop ID
    // In production, this should show a shop picker

    final request = ConsignmentRequest(
      productId: _selectedProduct!.id,
      shopId: 1, // TODO: Replace with selected shop
      quantity: int.parse(_quantityController.text),
      sellingPrice: double.parse(
        _sellingPriceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      ),
      commissionPercent: double.parse(_commissionController.text),
      consignmentDate: _consignmentDate,
      expiryDate: _expiryDate,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    context.read<ConsignmentBloc>().add(CreateConsignment(request));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Titipkan Produk')),
      body: BlocListener<ConsignmentBloc, ConsignmentState>(
        listener: (context, state) {
          if (state is ConsignmentCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Titipan berhasil dibuat!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is ConsignmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: _loadingProducts
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Product Picker
                    Text('Produk', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Product>(
                      value: _selectedProduct,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Pilih produk',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      items: _products.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p.name));
                      }).toList(),
                      onChanged: (p) {
                        setState(() {
                          _selectedProduct = p;
                          if (p != null) {
                            _sellingPriceController.text = p.basePrice
                                .toStringAsFixed(0);
                          }
                        });
                      },
                      validator: (v) => v == null ? 'Pilih produk' : null,
                    ),
                    const SizedBox(height: 16),

                    // Quantity
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Masukkan jumlah';
                        if (int.tryParse(v) == null || int.parse(v) <= 0) {
                          return 'Jumlah harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selling Price
                    TextFormField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Harga Jual',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sell),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Masukkan harga';
                        if (double.tryParse(v) == null ||
                            double.parse(v) <= 0) {
                          return 'Harga harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Commission
                    TextFormField(
                      controller: _commissionController,
                      decoration: const InputDecoration(
                        labelText: 'Komisi Toko (%)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.percent),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Masukkan komisi';
                        final val = double.tryParse(v);
                        if (val == null || val < 0 || val > 100) {
                          return 'Komisi harus 0-100%';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: _DatePickerField(
                            label: 'Tanggal Titip',
                            value: _consignmentDate,
                            onChanged: (d) =>
                                setState(() => _consignmentDate = d),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DatePickerField(
                            label: 'Kadaluarsa',
                            value: _expiryDate,
                            onChanged: (d) => setState(() => _expiryDate = d),
                            firstDate: _consignmentDate ?? DateTime.now(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    BlocBuilder<ConsignmentBloc, ConsignmentState>(
                      builder: (context, state) {
                        final isLoading = state is ConsignmentLoading;
                        return FilledButton.icon(
                          onPressed: isLoading ? null : _submit,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Titipkan Produk'),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate:
              firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null ? dateFormat.format(value!) : 'Pilih tanggal',
          style: TextStyle(
            color: value != null ? null : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}
