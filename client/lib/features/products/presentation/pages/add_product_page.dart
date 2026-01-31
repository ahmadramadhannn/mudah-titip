import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/product.dart';
import '../../data/models/product_request.dart';
import '../bloc/product_bloc.dart';

class AddProductPage extends StatefulWidget {
  final Product? productToEdit;

  const AddProductPage({super.key, this.productToEdit});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _basePriceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _shelfLifeDaysController;
  bool _isLoading = false;

  bool get _isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productToEdit?.name);
    _descriptionController = TextEditingController(
      text: widget.productToEdit?.description,
    );
    _basePriceController = TextEditingController(
      text: widget.productToEdit?.basePrice.toStringAsFixed(0),
    );
    _categoryController = TextEditingController(
      text: widget.productToEdit?.category,
    );
    _shelfLifeDaysController = TextEditingController(
      text: widget.productToEdit?.shelfLifeDays?.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _categoryController.dispose();
    _shelfLifeDaysController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final basePrice = double.tryParse(_basePriceController.text) ?? 0;
      final category = _categoryController.text.trim();
      final shelfLifeDays = int.tryParse(_shelfLifeDaysController.text);

      if (_isEditing) {
        context.read<ProductBloc>().add(
          ProductUpdateRequested(
            id: widget.productToEdit!.id,
            request: UpdateProductRequest(
              name: name,
              description: description.isNotEmpty ? description : null,
              basePrice: basePrice,
              category: category.isNotEmpty ? category : null,
              shelfLifeDays: shelfLifeDays,
            ),
          ),
        );
      } else {
        context.read<ProductBloc>().add(
          ProductCreateRequested(
            CreateProductRequest(
              name: name,
              description: description.isNotEmpty ? description : null,
              basePrice: basePrice,
              category: category.isNotEmpty ? category : null,
              shelfLifeDays: shelfLifeDays,
            ),
          ),
        );
      }
    }
  }

  void _onDelete() {
    if (!_isEditing) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: const Text(
          'Produk yang dihapus tidak dapat dikembalikan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.read<ProductBloc>().add(
                ProductDeleteRequested(widget.productToEdit!.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        setState(() => _isLoading = state is ProductLoading);

        if (state is ProductOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop(); // Go back to list
        }

        if (state is ProductFailure) {
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
          title: Text(_isEditing ? 'Ubah Produk' : 'Tambah Produk'),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: _isLoading ? null : _onDelete,
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image picker placeholder
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral300),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload Foto Produk',
                          style: TextStyle(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    hintText: 'Contoh: Keripik Pisang Coklat',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama produk wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _basePriceController,
                  decoration: const InputDecoration(
                    labelText: 'Harga Dasar (Rp)',
                    hintText: '0',
                    prefixIcon: Icon(Icons.attach_money_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga wajib diisi';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Format harga tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori (Opsional)',
                    hintText: 'Contoh: Makanan Ringan',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _shelfLifeDaysController,
                  decoration: const InputDecoration(
                    labelText: 'Masa Simpan (Hari, Opsional)',
                    hintText: 'Contoh: 30',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (int.tryParse(value) == null) {
                        return 'Format tidak valid';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
                    hintText: 'Jelaskan detail produk anda...',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Produk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
