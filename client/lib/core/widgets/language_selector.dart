import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../locale/locale_cubit.dart';

/// A widget for toggling between languages.
/// Can be used as a dropdown, switch, or segmented button.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return PopupMenuButton<String>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                state.locale.languageCode.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          tooltip: 'Change language',
          onSelected: (languageCode) {
            if (kDebugMode) {
              print('🌐 Language selected: $languageCode');
            }
            context.read<LocaleCubit>().changeLocale(Locale(languageCode));
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'id',
              child: Row(
                children: [
                  if (state.locale.languageCode == 'id')
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  else
                    const SizedBox(width: 24),
                  const SizedBox(width: 8),
                  const Text('🇮🇩 Indonesia'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'en',
              child: Row(
                children: [
                  if (state.locale.languageCode == 'en')
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  else
                    const SizedBox(width: 24),
                  const SizedBox(width: 8),
                  const Text('🇬🇧 English'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A simple toggle switch for language.
class LanguageToggleSwitch extends StatelessWidget {
  const LanguageToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final isEnglish = state.locale.languageCode == 'en';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🇮🇩',
              style: TextStyle(
                fontSize: 20,
                color: !isEnglish ? null : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
            Switch(
              value: isEnglish,
              onChanged: (_) => context.read<LocaleCubit>().toggleLocale(),
            ),
            Text(
              '🇬🇧',
              style: TextStyle(
                fontSize: 20,
                color: isEnglish ? null : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A tile for use in settings/profile pages.
class LanguageSettingsTile extends StatelessWidget {
  const LanguageSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final isIndonesian = state.locale.languageCode == 'id';

        return ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language / Bahasa'),
          subtitle: Text(isIndonesian ? 'Indonesia' : 'English'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(context, state.locale.languageCode),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, String currentLocale) {
    // Capture the LocaleCubit before showing the dialog
    final localeCubit = context.read<LocaleCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Language / Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text('🇮🇩', style: TextStyle(fontSize: 24)),
              title: const Text('Indonesia'),
              trailing: currentLocale == 'id'
                  ? Icon(
                      Icons.check,
                      color: Theme.of(dialogContext).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                if (kDebugMode) {
                  print('🌐 Changing locale to: id');
                }
                localeCubit.changeLocale(const Locale('id'));
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              leading: Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: currentLocale == 'en'
                  ? Icon(
                      Icons.check,
                      color: Theme.of(dialogContext).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                if (kDebugMode) {
                  print('🌐 Changing locale to: en');
                }
                localeCubit.changeLocale(const Locale('en'));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
