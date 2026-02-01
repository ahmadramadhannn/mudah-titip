import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/image_upload_service.dart';
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
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _selectImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto'),
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
                title: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: AppColors.error),
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
          _uploadedImageUrl =
              null; // Clear existing URL when new image selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) {
      return _uploadedImageUrl; // Return existing URL if no new image
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
            content: Text('Gagal mengupload gambar: $e'),
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

      // Upload image first if a new one is selected
      String? imageUrl = _uploadedImageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
        // If upload failed and we needed to upload, stop here
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
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Mengupload gambar...'),
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
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Text(
                          'Ketuk untuk ganti foto',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
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
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Text(
                          'Ketuk untuk ganti foto',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
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
          Text(
            'Upload Foto Produk',
            style: TextStyle(color: AppColors.neutral500),
          ),
          const SizedBox(height: 4),
          Text(
            'Ketuk untuk memilih gambar',
            style: TextStyle(color: AppColors.neutral400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // Image picker
                _buildImagePicker(),
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
