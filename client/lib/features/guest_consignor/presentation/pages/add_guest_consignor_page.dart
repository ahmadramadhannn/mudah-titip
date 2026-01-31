import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/guest_consignor.dart';
import '../../data/models/guest_consignor_request.dart';
import '../../data/repositories/guest_consignor_repository.dart';
import '../bloc/guest_consignor_bloc.dart';

/// Page for adding or editing a guest consignor.
class AddGuestConsignorPage extends StatelessWidget {
  final GuestConsignor? editConsignor;

  const AddGuestConsignorPage({super.key, this.editConsignor});

  bool get isEditing => editConsignor != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GuestConsignorBloc(getIt<GuestConsignorRepository>()),
      child: _AddGuestConsignorContent(
        editConsignor: editConsignor,
        isEditing: isEditing,
      ),
    );
  }
}

class _AddGuestConsignorContent extends StatefulWidget {
  final GuestConsignor? editConsignor;
  final bool isEditing;

  const _AddGuestConsignorContent({
    required this.editConsignor,
    required this.isEditing,
  });

  @override
  State<_AddGuestConsignorContent> createState() =>
      _AddGuestConsignorContentState();
}

class _AddGuestConsignorContentState extends State<_AddGuestConsignorContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editConsignor != null) {
      _nameController.text = widget.editConsignor!.name;
      _phoneController.text = widget.editConsignor!.phone;
      _addressController.text = widget.editConsignor!.address ?? '';
      _notesController.text = widget.editConsignor!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = GuestConsignorRequest(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (widget.isEditing) {
        context.read<GuestConsignorBloc>().add(
          GuestConsignorUpdateRequested(
            id: widget.editConsignor!.id,
            request: request,
          ),
        );
      } else {
        context.read<GuestConsignorBloc>().add(
          GuestConsignorCreateRequested(request: request),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestConsignorBloc, GuestConsignorState>(
      listener: (context, state) {
        setState(() => _isLoading = state is GuestConsignorLoading);

        if (state is GuestConsignorOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
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
          title: Text(widget.isEditing ? 'Edit Penitip' : 'Tambah Penitip'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Penitip ini tidak perlu mengunduh aplikasi. '
                          'Anda akan mengelola produk dan titipan mereka.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name field
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama Penitip *',
                    hintText: 'Masukkan nama penitip',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    if (value.trim().length < 2) {
                      return 'Nama minimal 2 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon *',
                    hintText: 'Contoh: 081234567890',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nomor telepon wajib diisi';
                    }
                    if (value.trim().length < 8) {
                      return 'Nomor telepon minimal 8 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address field
                TextFormField(
                  controller: _addressController,
                  textInputAction: TextInputAction.next,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alamat (Opsional)',
                    hintText: 'Masukkan alamat penitip',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes field
                TextFormField(
                  controller: _notesController,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    hintText: 'Tambahkan catatan tentang penitip ini',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit button
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
                      : Text(widget.isEditing ? 'Simpan' : 'Tambah Penitip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
