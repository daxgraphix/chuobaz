import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/local_cache.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String language;
  final bool notificationsEnabled;
  final bool privateProfile;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.language = 'English',
    this.notificationsEnabled = true,
    this.privateProfile = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? privateProfile,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      privateProfile: privateProfile ?? this.privateProfile,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  void _load() {
    final box = LocalCache.box(LocalCache.settingsBox);
    final themeIndex = box.get('theme_mode', defaultValue: ThemeMode.system.index) as int;
    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      language: box.get('language', defaultValue: 'English') as String,
      notificationsEnabled: box.get('notifications_enabled', defaultValue: true) as bool,
      privateProfile: box.get('private_profile', defaultValue: false) as bool,
    );
  }

  void setThemeMode(ThemeMode mode) {
    LocalCache.box(LocalCache.settingsBox).put('theme_mode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setLanguage(String language) {
    LocalCache.box(LocalCache.settingsBox).put('language', language);
    state = state.copyWith(language: language);
  }

  void setNotificationsEnabled(bool enabled) {
    LocalCache.box(LocalCache.settingsBox).put('notifications_enabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void setPrivateProfile(bool isPrivate) {
    LocalCache.box(LocalCache.settingsBox).put('private_profile', isPrivate);
    state = state.copyWith(privateProfile: isPrivate);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier());
