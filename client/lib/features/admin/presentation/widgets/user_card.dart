import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/user_admin.dart';
import '../../../../core/theme/app_colors.dart';

/// Mobile-optimized card for displaying user information
class UserCard extends StatelessWidget {
  final UserAdmin user;
  final VoidCallback? onSuspend;
  final VoidCallback? onActivate;
  final VoidCallback? onBan;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.onSuspend,
    this.onActivate,
    this.onBan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name and Status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 12),

              // Role and Join Date
              Row(
                children: [
                  _buildRoleBadge(),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(user.createdAt),
                    style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats
              Row(
                children: [
                  _buildStat(
                    Icons.inventory,
                    '${user.totalProducts}',
                    'Products',
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    Icons.local_shipping,
                    '${user.totalConsignments}',
                    'Consignments',
                  ),
                  const SizedBox(width: 16),
                  _buildStat(Icons.shopping_bag, '${user.totalSales}', 'Sales'),
                ],
              ),

              // Action Buttons
              if (onSuspend != null || onActivate != null || onBan != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (user.status == 'ACTIVE' && onSuspend != null)
                      TextButton.icon(
                        onPressed: onSuspend,
                        icon: const Icon(Icons.pause, size: 16),
                        label: const Text('Suspend'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.warning,
                        ),
                      ),
                    if (user.status == 'SUSPENDED' && onActivate != null)
                      TextButton.icon(
                        onPressed: onActivate,
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Activate'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.success,
                        ),
                      ),
                    if (user.status == 'ACTIVE' && onBan != null)
                      TextButton.icon(
                        onPressed: onBan,
                        icon: const Icon(Icons.block, size: 16),
                        label: const Text('Ban'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;

    switch (user.status) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            user.status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    Color color;
    String label;

    switch (user.role) {
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
        label = user.role;
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.neutral600),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: AppColors.neutral500),
            ),
          ],
        ),
      ],
    );
  }
}
