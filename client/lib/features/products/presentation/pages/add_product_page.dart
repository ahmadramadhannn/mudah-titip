import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
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
  late final TextEditingController _stockController;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  // Image handling
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _uploadedImageUrl;

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
    _stockController = TextEditingController(
      text: widget.productToEdit?.stock.toString() ?? '0',
    );
    // Set existing image URL if editing
    _uploadedImageUrl = widget.productToEdit?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _categoryController.dispose();
    _shelfLifeDaysController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.selectProduct), // Using as placeholder
              onTap: () {
                Navigator.pop(context);
                _selectImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _selectImage(ImageSource.camera);
              },
            ),
            if (_selectedImage != null || _uploadedImageUrl != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  l10n.delete,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _uploadedImageUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _uploadedImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) {
      return _uploadedImageUrl;
    }

    setState(() => _isUploadingImage = true);

    try {
      final imageUploadService = getIt<ImageUploadService>();
      final url = await imageUploadService.uploadImage(
        _selectedImage!,
        folder: 'products',
      );
      setState(() {
        _uploadedImageUrl = url;
        _isUploadingImage = false;
      });
      return url;
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      String? imageUrl = _uploadedImageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null && _selectedImage != null) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final basePrice = double.tryParse(_basePriceController.text) ?? 0;
      final category = _categoryController.text.trim();
      final shelfLifeDays = int.tryParse(_shelfLifeDaysController.text);
      final stock = int.tryParse(_stockController.text) ?? 0;

      if (_isEditing) {
        context.read<ProductBloc>().add(
          ProductUpdateRequested(
            id: widget.productToEdit!.id,
            request: UpdateProductRequest(
              name: name,
              description: description.isNotEmpty ? description : null,
              basePrice: basePrice,
              stock: stock,
              category: category.isNotEmpty ? category : null,
              shelfLifeDays: shelfLifeDays,
              imageUrl: imageUrl,
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
              stock: stock,
              category: category.isNotEmpty ? category : null,
              shelfLifeDays: shelfLifeDays,
              imageUrl: imageUrl,
            ),
          ),
        );
      }
    }
  }

  void _onDelete() {
    if (!_isEditing) return;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.delete} ${l10n.product}?'),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              context.pop();
              context.read<ProductBloc>().add(
                ProductDeleteRequested(widget.productToEdit!.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage = _selectedImage != null || _uploadedImageUrl != null;

    return GestureDetector(
      onTap: _isLoading ? null : _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? AppColors.primary : AppColors.neutral300,
            width: hasImage ? 2 : 1,
          ),
        ),
        child: _isUploadingImage
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.loading),
                  ],
                ),
              )
            : _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedImage!, fit: BoxFit.cover),
                    _buildImageOverlay(),
                  ],
                ),
              )
            : _uploadedImageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _uploadedImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    ),
                    _buildImageOverlay(),
                  ],
                ),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImageOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.edit,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: 8),
          Text(l10n.addProduct, style: TextStyle(color: AppColors.neutral500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is! ProductLoading) {
          setState(() => _isLoading = false);
        }

        if (state is ProductOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
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
          title: Text(_isEditing ? l10n.editProduct : l10n.addProduct),
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
                _buildImagePicker(),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.productName,
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _basePriceController,
                  decoration: InputDecoration(
                    labelText: '${l10n.basePrice} (Rp)',
                    prefixIcon: const Icon(Icons.attach_money_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    if (double.tryParse(value) == null) {
                      return l10n.invalidEmail; // Reusing as "invalid format"
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: l10n.stock,
                    prefixIcon: const Icon(Icons.numbers_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    if (int.tryParse(value) == null) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: '${l10n.category} (Optional)',
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _shelfLifeDaysController,
                  decoration: InputDecoration(
                    labelText: '${l10n.shelfLife} (Optional)',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: '${l10n.productDescription} (Optional)',
                    prefixIcon: const Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: (_isLoading || _isUploadingImage)
                      ? null
                      : _onSubmit,
                  child: (_isLoading || _isUploadingImage)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
