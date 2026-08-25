import 'package:flutter/material.dart';

import 'app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Theme',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  title: const Text('Light mode'),
                  onChanged: (value) {
                    if (value != null) settings.setThemeMode(value);
                  },
                ),
              ),
              Card(
                child: RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  title: const Text('Dark mode'),
                  onChanged: (value) {
                    if (value != null) settings.setThemeMode(value);
                  },
                ),
              ),
              Card(
                child: RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  title: const Text('System default'),
                  onChanged: (value) {
                    if (value != null) settings.setThemeMode(value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
