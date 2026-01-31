import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/profile_response.dart';
import '../../data/repositories/profile_repository.dart';
import '../bloc/profile_bloc.dart';

/// Profile page for managing user profile.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfileBloc(getIt<ProfileRepository>())
            ..add(const ProfileLoadRequested()),
      child: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent();

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditingName = false;
  bool _isEditingPhone = false;
  bool _isEditingEmail = false;
  bool _isEditingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          _showMessage(state.message);
          setState(() {
            _isEditingName = false;
            _isEditingPhone = false;
            _isEditingEmail = false;
            _isEditingPassword = false;
          });
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else if (state is ProfileError) {
          _showMessage(state.message, isError: true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state is ProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileError && state.profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<ProfileBloc>().add(const ProfileLoadRequested()),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final profile = _getProfile(state);
    if (profile == null) return const SizedBox.shrink();

    final isUpdating = state is ProfileUpdating;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          _buildProfileHeader(profile),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Profile info section
          Text(
            'Informasi Profil',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Name field
          _buildEditableField(
            label: 'Nama',
            value: profile.name,
            controller: _nameController,
            isEditing: _isEditingName,
            isLoading: isUpdating && _isEditingName,
            onEdit: () {
              setState(() {
                _nameController.text = profile.name;
                _isEditingName = true;
              });
            },
            onCancel: () => setState(() => _isEditingName = false),
            onSave: () {
              if (_nameController.text.trim().length >= 2) {
                context.read<ProfileBloc>().add(
                  ProfileUpdateRequested(name: _nameController.text.trim()),
                );
              } else {
                _showMessage('Nama minimal 2 karakter', isError: true);
              }
            },
          ),
          const SizedBox(height: 16),

          // Phone field
          _buildEditableField(
            label: 'Nomor Telepon',
            value: profile.phone ?? 'Belum diisi',
            controller: _phoneController,
            isEditing: _isEditingPhone,
            isLoading: isUpdating && _isEditingPhone,
            keyboardType: TextInputType.phone,
            onEdit: () {
              setState(() {
                _phoneController.text = profile.phone ?? '';
                _isEditingPhone = true;
              });
            },
            onCancel: () => setState(() => _isEditingPhone = false),
            onSave: () {
              context.read<ProfileBloc>().add(
                ProfileUpdateRequested(phone: _phoneController.text.trim()),
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Security section
          Text('Keamanan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          // Email field
          _buildSecurityField(
            label: 'Email',
            value: profile.email,
            isEditing: _isEditingEmail,
            isLoading: isUpdating && _isEditingEmail,
            onEdit: () {
              setState(() {
                _emailController.text = profile.email;
                _currentPasswordController.clear();
                _isEditingEmail = true;
              });
            },
            onCancel: () => setState(() => _isEditingEmail = false),
            editContent: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Baru',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Password Saat Ini',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureCurrentPassword = !_obscureCurrentPassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _isEditingEmail = false),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isUpdating
                          ? null
                          : () {
                              if (_emailController.text.contains('@') &&
                                  _currentPasswordController.text.isNotEmpty) {
                                context.read<ProfileBloc>().add(
                                  ProfileEmailUpdateRequested(
                                    newEmail: _emailController.text.trim(),
                                    currentPassword:
                                        _currentPasswordController.text,
                                  ),
                                );
                              } else {
                                _showMessage(
                                  'Lengkapi email dan password',
                                  isError: true,
                                );
                              }
                            },
                      child: isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Password field
          _buildSecurityField(
            label: 'Password',
            value: '••••••••',
            isEditing: _isEditingPassword,
            isLoading: isUpdating && _isEditingPassword,
            onEdit: () {
              setState(() {
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
                _isEditingPassword = true;
              });
            },
            onCancel: () => setState(() => _isEditingPassword = false),
            editContent: Column(
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Password Saat Ini',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureCurrentPassword = !_obscureCurrentPassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    hintText: 'Minimal 6 karakter',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () =>
                          setState(() => _isEditingPassword = false),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isUpdating
                          ? null
                          : () {
                              if (_currentPasswordController.text.isEmpty ||
                                  _newPasswordController.text.isEmpty) {
                                _showMessage(
                                  'Lengkapi semua field',
                                  isError: true,
                                );
                                return;
                              }
                              if (_newPasswordController.text.length < 6) {
                                _showMessage(
                                  'Password minimal 6 karakter',
                                  isError: true,
                                );
                                return;
                              }
                              if (_newPasswordController.text !=
                                  _confirmPasswordController.text) {
                                _showMessage(
                                  'Konfirmasi password tidak cocok',
                                  isError: true,
                                );
                                return;
                              }
                              context.read<ProfileBloc>().add(
                                ProfilePasswordUpdateRequested(
                                  currentPassword:
                                      _currentPasswordController.text,
                                  newPassword: _newPasswordController.text,
                                ),
                              );
                            },
                      child: isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Account info
          Text(
            'Informasi Akun',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tipe Akun', profile.role.displayName),
          const SizedBox(height: 8),
          _buildInfoRow('Bergabung', _formatDate(profile.createdAt)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileResponse profile) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              profile.role.displayName,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    required bool isLoading,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    TextInputType keyboardType = TextInputType.text,
  }) {
    if (isEditing) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(labelText: label),
                enabled: !isLoading,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoading ? null : onCancel,
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading ? null : onSave,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: onEdit,
      ),
    );
  }

  Widget _buildSecurityField({
    required String label,
    required String value,
    required bool isEditing,
    required bool isLoading,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required Widget editContent,
  }) {
    if (isEditing) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ubah $label',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
              editContent,
            ],
          ),
        ),
      );
    }

    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: onEdit,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  ProfileResponse? _getProfile(ProfileState state) {
    if (state is ProfileLoading) return state.profile;
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileUpdating) return state.profile;
    if (state is ProfileUpdateSuccess) return state.profile;
    if (state is ProfileError) return state.profile;
    return null;
  }
}
