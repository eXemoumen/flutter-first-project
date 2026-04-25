import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';
import '../../widgets/responsive_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ResponsivePage(
        maxWidth: 860,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: const Text('Use dark appearance across the app'),
                value: settings.isDarkMode,
                onChanged: (enabled) {
                  ref.read(settingsProvider).toggleDarkMode(enabled);
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Theme mode: System default'),
                subtitle: const Text('Follow device theme automatically'),
                trailing: Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(settingsProvider).setThemeMode(value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

