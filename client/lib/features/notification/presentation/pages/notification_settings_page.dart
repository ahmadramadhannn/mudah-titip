import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification_preferences_model.dart';
import '../../data/repositories/notification_repository.dart';

/// Page for managing notification preferences.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  NotificationPreferencesModel? _preferences;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = context.read<NotificationRepository>();
      final prefs = await repo.getPreferences();
      setState(() {
        _preferences = prefs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat pengaturan: $e';
        _loading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    if (_preferences == null) return;

    setState(() {
      _saving = true;
    });

    try {
      final repo = context.read<NotificationRepository>();
      final updated = await repo.updatePreferences(_preferences!);
      setState(() {
        _preferences = updated;
        _saving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pengaturan tersimpan')));
      }
    } catch (e) {
      setState(() {
        _saving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  void _updatePreference(NotificationPreferencesModel Function() updater) {
    setState(() {
      _preferences = updater();
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Notifikasi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: TextStyle(color: colorScheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPreferences,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    final prefs = _preferences!;

    return ListView(
      children: [
        // Stock Notifications
        _SectionHeader(title: 'Stok & Inventori'),
        SwitchListTile(
          title: const Text('Stok Menipis'),
          subtitle: const Text('Notifikasi saat stok hampir habis'),
          value: prefs.stockLowEnabled,
          onChanged: (value) =>
              _updatePreference(() => prefs.copyWith(stockLowEnabled: value)),
        ),
        if (prefs.stockLowEnabled)
          ListTile(
            title: const Text('Batas Stok Menipis'),
            subtitle: Text('Notifikasi jika stok ≤ ${prefs.lowStockThreshold}'),
            trailing: DropdownButton<int>(
              value: prefs.lowStockThreshold,
              items: [3, 5, 10, 15, 20]
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
              onChanged: (value) => _updatePreference(
                () => prefs.copyWith(lowStockThreshold: value),
              ),
            ),
          ),
        SwitchListTile(
          title: const Text('Stok Habis'),
          subtitle: const Text('Notifikasi saat stok benar-benar habis'),
          value: prefs.stockOutEnabled,
          onChanged: (value) =>
              _updatePreference(() => prefs.copyWith(stockOutEnabled: value)),
        ),
        SwitchListTile(
          title: const Text('Ringkasan Mingguan'),
          subtitle: const Text('Laporan stok setiap hari Senin'),
          value: prefs.weeklySummaryEnabled,
          onChanged: (value) => _updatePreference(
            () => prefs.copyWith(weeklySummaryEnabled: value),
          ),
        ),
        const Divider(),

        // Agreement Notifications
        _SectionHeader(title: 'Perjanjian'),
        SwitchListTile(
          title: const Text('Pembaruan Perjanjian'),
          subtitle: const Text('Proposal, persetujuan, penolakan, dll.'),
          value: prefs.agreementUpdatesEnabled,
          onChanged: (value) => _updatePreference(
            () => prefs.copyWith(agreementUpdatesEnabled: value),
          ),
        ),
        const Divider(),

        // Sales Notifications
        _SectionHeader(title: 'Penjualan'),
        SwitchListTile(
          title: const Text('Penjualan Tercatat'),
          subtitle: const Text('Notifikasi setiap ada penjualan'),
          value: prefs.salesNotificationsEnabled,
          onChanged: (value) => _updatePreference(
            () => prefs.copyWith(salesNotificationsEnabled: value),
          ),
        ),
        const Divider(),

        // Expiry Notifications
        _SectionHeader(title: 'Konsinyasi'),
        SwitchListTile(
          title: const Text('Pengingat Kadaluarsa'),
          subtitle: const Text('Notifikasi sebelum konsinyasi berakhir'),
          value: prefs.expiryRemindersEnabled,
          onChanged: (value) => _updatePreference(
            () => prefs.copyWith(expiryRemindersEnabled: value),
          ),
        ),
        if (prefs.expiryRemindersEnabled)
          ListTile(
            title: const Text('Hari Pengingat'),
            subtitle: Text(
              'Ingatkan ${prefs.expiryReminderDays} hari sebelum berakhir',
            ),
            trailing: DropdownButton<int>(
              value: prefs.expiryReminderDays,
              items: [3, 5, 7, 14, 21, 30]
                  .map(
                    (v) => DropdownMenuItem(value: v, child: Text('$v hari')),
                  )
                  .toList(),
              onChanged: (value) => _updatePreference(
                () => prefs.copyWith(expiryReminderDays: value),
              ),
            ),
          ),
        const Divider(),

        // Financial Notifications
        _SectionHeader(title: 'Keuangan'),
        SwitchListTile(
          title: const Text('Pembayaran Siap'),
          subtitle: const Text('Notifikasi saat ada pembayaran'),
          value: prefs.payoutNotificationsEnabled,
          onChanged: (value) => _updatePreference(
            () => prefs.copyWith(payoutNotificationsEnabled: value),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
