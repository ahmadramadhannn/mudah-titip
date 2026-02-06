import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../data/models/user_admin.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../widgets/user_card.dart';

/// User management page for admin
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String? _selectedRole;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    context.read<AdminBloc>().add(
      LoadUsers(role: _selectedRole, status: _selectedStatus),
    );
  }

  Widget _buildRoleFilter() {
    return SizedBox(
      width: ResponsiveHelper.isMobile(context) ? double.infinity : 200,
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: const InputDecoration(
          labelText: 'Role',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: null, child: Text('All Roles')),
          DropdownMenuItem(value: 'SHOP_OWNER', child: Text('Shop Owner')),
          DropdownMenuItem(value: 'CONSIGNOR', child: Text('Consignor')),
          DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('Super Admin')),
        ],
        onChanged: (value) {
          setState(() => _selectedRole = value);
          _loadUsers();
        },
      ),
    );
  }

  Widget _buildStatusFilter() {
    return SizedBox(
      width: ResponsiveHelper.isMobile(context) ? double.infinity : 200,
      child: DropdownButtonFormField<String>(
        value: _selectedStatus,
        decoration: const InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: null, child: Text('All Statuses')),
          DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
          DropdownMenuItem(value: 'SUSPENDED', child: Text('Suspended')),
          DropdownMenuItem(value: 'BANNED', child: Text('Banned')),
        ],
        onChanged: (value) {
          setState(() => _selectedStatus = value);
          _loadUsers();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: ResponsiveHelper.isMobile(context)
                ? Column(
                    children: [
                      _buildRoleFilter(),
                      const SizedBox(height: 12),
                      _buildStatusFilter(),
                    ],
                  )
                : Row(
                    children: [
                      _buildRoleFilter(),
                      const SizedBox(width: 16),
                      _buildStatusFilter(),
                    ],
                  ),
          ),

          // Data table
          Expanded(
            child: BlocConsumer<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is UserActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadUsers();
                } else if (state is AdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UsersLoaded) {
                  return _buildUserTable(state.users);
                }

                return const Center(child: Text('No users found'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(List<UserAdmin> users) {
    // Use card layout for mobile, table for desktop
    if (ResponsiveHelper.isMobile(context)) {
      return _buildUserList(users);
    }

    final dateFormat = DateFormat('dd MMM yyyy');

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 900,
      columns: const [
        DataColumn2(label: Text('ID'), size: ColumnSize.S),
        DataColumn2(label: Text('Name'), size: ColumnSize.L),
        DataColumn2(label: Text('Email'), size: ColumnSize.L),
        DataColumn2(label: Text('Role'), size: ColumnSize.M),
        DataColumn2(label: Text('Status'), size: ColumnSize.M),
        DataColumn2(label: Text('Joined'), size: ColumnSize.M),
        DataColumn2(label: Text('Products'), size: ColumnSize.S),
        DataColumn2(label: Text('Actions'), size: ColumnSize.M),
      ],
      rows: users.map((user) {
        return DataRow2(
          cells: [
            DataCell(Text(user.id.toString())),
            DataCell(Text(user.name)),
            DataCell(Text(user.email)),
            DataCell(_buildRoleBadge(user.role)),
            DataCell(_buildStatusBadge(user.status)),
            DataCell(Text(dateFormat.format(user.createdAt))),
            DataCell(Text(user.totalProducts.toString())),
            DataCell(_buildActionButtons(user)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildUserList(List<UserAdmin> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          user: user,
          onSuspend: user.status == 'ACTIVE'
              ? () => _showSuspendDialog(user)
              : null,
          onActivate: user.status == 'SUSPENDED'
              ? () => _activateUser(user)
              : null,
          onBan: user.status == 'ACTIVE' ? () => _showBanDialog(user) : null,
        );
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    String label;

    switch (role) {
      case 'SHOP_OWNER':
        color = AppColors.primary;
        label = 'Shop Owner';
        break;
      case 'CONSIGNOR':
        color = AppColors.secondary;
        label = 'Consignor';
        break;
      case 'SUPER_ADMIN':
        color = AppColors.error;
        label = 'Admin';
        break;
      default:
        color = AppColors.neutral500;
        label = role;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'ACTIVE':
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'SUSPENDED':
        color = AppColors.warning;
        icon = Icons.pause_circle;
        break;
      case 'BANNED':
        color = AppColors.error;
        icon = Icons.block;
        break;
      default:
        color = AppColors.neutral500;
        icon = Icons.help;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(UserAdmin user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (user.status == 'ACTIVE') ...[
          IconButton(
            icon: const Icon(Icons.pause, size: 18),
            onPressed: () => _showSuspendDialog(user),
            tooltip: 'Suspend',
            color: AppColors.warning,
          ),
          IconButton(
            icon: const Icon(Icons.block, size: 18),
            onPressed: () => _showBanDialog(user),
            tooltip: 'Ban',
            color: AppColors.error,
          ),
        ] else if (user.status == 'SUSPENDED') ...[
          IconButton(
            icon: const Icon(Icons.check_circle, size: 18),
            onPressed: () => _activateUser(user),
            tooltip: 'Activate',
            color: AppColors.success,
          ),
        ],
      ],
    );
  }

  void _showSuspendDialog(UserAdmin user) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to suspend ${user.name}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                context.read<AdminBloc>().add(
                  SuspendUser(user.id, reasonController.text),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(UserAdmin user) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to permanently ban ${user.name}?'),
            const SizedBox(height: 8),
            const Text(
              'This action is severe and should only be used for serious violations.',
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (required)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                context.read<AdminBloc>().add(
                  BanUser(user.id, reasonController.text),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Ban User'),
          ),
        ],
      ),
    );
  }

  void _activateUser(UserAdmin user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate User'),
        content: Text('Reactivate ${user.name}\'s account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(ActivateUser(user.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }
}
