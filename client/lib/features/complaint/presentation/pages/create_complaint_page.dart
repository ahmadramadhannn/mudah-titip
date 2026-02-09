import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/image_upload_service.dart';
import '../../data/models/complaint_model.dart';
import '../bloc/complaint_bloc.dart';

/// Page for creating a new complaint.
class CreateComplaintPage extends StatefulWidget {
  final int consignmentId;
  final String? productName;

  const CreateComplaintPage({
    super.key,
    required this.consignmentId,
    this.productName,
  });

  @override
  State<CreateComplaintPage> createState() => _CreateComplaintPageState();
}

class _CreateComplaintPageState extends State<CreateComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  ComplaintCategory _selectedCategory = ComplaintCategory.qualityIssue;
  final List<File> _selectedMedia = [];
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Kamera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galeri'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source == null) return;

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
      );

      if (file != null) {
        setState(() {
          _selectedMedia.add(File(file.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih file: $e')));
      }
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      // Upload media files
      List<String>? mediaUrls;
      if (_selectedMedia.isNotEmpty) {
        final uploadService = context.read<ImageUploadService>();
        mediaUrls = [];
        for (final file in _selectedMedia) {
          final url = await uploadService.uploadImage(
            file,
            folder: 'complaints',
          );
          mediaUrls.add(url);
        }
      }

      // Create complaint
      if (mounted) {
        context.read<ComplaintBloc>().add(
          CreateComplaint(
            consignmentId: widget.consignmentId,
            category: _selectedCategory,
            description: _descriptionController.text.trim(),
            mediaUrls: mediaUrls,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengunggah file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComplaintBloc, ComplaintState>(
      listener: (context, state) {
        if (state is ComplaintSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Keluhan berhasil dikirim'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is ComplaintError) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Laporkan Masalah')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.productName != null) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(widget.productName!),
                    subtitle: const Text('Produk yang dilaporkan'),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Category Selection
              const Text(
                'Kategori Masalah',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ComplaintCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Masalah',
                  hintText: 'Jelaskan masalah yang terjadi...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  if (value.trim().length < 10) {
                    return 'Deskripsi minimal 10 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Media Selection
              const Text(
                'Foto/Video Bukti',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (_selectedMedia.isNotEmpty) ...[
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedMedia.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == _selectedMedia.length) {
                        return _AddMediaButton(onTap: _pickMedia);
                      }
                      return _MediaPreview(
                        file: _selectedMedia[index],
                        onRemove: () => _removeMedia(index),
                      );
                    },
                  ),
                ),
              ] else ...[
                _AddMediaButton(onTap: _pickMedia, fullWidth: true),
              ],

              const SizedBox(height: 32),

              // Submit Button
              BlocBuilder<ComplaintBloc, ComplaintState>(
                builder: (context, state) {
                  final isLoading =
                      state is ComplaintSubmitting || _isUploading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Kirim Keluhan'),
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

class _AddMediaButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool fullWidth;

  const _AddMediaButton({required this.onTap, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.grey),
            SizedBox(height: 4),
            Text('Tambah', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _MediaPreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
