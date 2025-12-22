import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/preferences_helper.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_loadInitialThemeMode());

  static ThemeMode _loadInitialThemeMode() {
    final mode = PreferencesHelper.getThemeMode();
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    switch (mode) {
      case ThemeMode.light:
        await PreferencesHelper.setThemeMode('light');
        break;
      case ThemeMode.dark:
        await PreferencesHelper.setThemeMode('dark');
        break;
      case ThemeMode.system:
        await PreferencesHelper.setThemeMode('system');
        break;
    }
    emit(mode);
  }
}
