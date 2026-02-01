import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_state.dart';

/// Cubit for managing app locale/language preference.
class LocaleCubit extends Cubit<LocaleState> {
  static const String _localeKey = 'app_locale';

  final SharedPreferences _prefs;

  LocaleCubit(this._prefs) : super(const LocaleState(Locale('id'))) {
    if (kDebugMode) {
      print('🌐 LocaleCubit initialized with default locale: id');
    }
    _loadSavedLocale();
  }

  /// Load saved locale from SharedPreferences
  void _loadSavedLocale() {
    final savedLocale = _prefs.getString(_localeKey);
    if (kDebugMode) {
      print('🌐 Loading saved locale from SharedPreferences: $savedLocale');
    }
    if (savedLocale != null) {
      emit(LocaleState(Locale(savedLocale)));
      if (kDebugMode) {
        print('🌐 Emitted loaded locale: $savedLocale');
      }
    }
  }

  /// Change the current locale
  Future<void> changeLocale(Locale locale) async {
    if (kDebugMode) {
      print('🌐 changeLocale called with: ${locale.languageCode}');
    }
    await _prefs.setString(_localeKey, locale.languageCode);
    if (kDebugMode) {
      print('🌐 Locale saved to SharedPreferences: ${locale.languageCode}');
    }
    emit(LocaleState(locale));
    if (kDebugMode) {
      print('🌐 Emitted new locale state: ${locale.languageCode}');
    }
  }

  /// Toggle between Indonesian and English
  Future<void> toggleLocale() async {
    final newLocale = state.locale.languageCode == 'id'
        ? const Locale('en')
        : const Locale('id');
    await changeLocale(newLocale);
  }

  /// Check if current locale is Indonesian
  bool get isIndonesian => state.locale.languageCode == 'id';

  /// Check if current locale is English
  bool get isEnglish => state.locale.languageCode == 'en';
}
