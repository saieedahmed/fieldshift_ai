import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/farm_data.dart';
import '../team/team_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.farm,
    required this.locale,
    required this.isDark,
    required this.onLanguageChanged,
    required this.onThemeChanged,
    required this.onChangeFarmLocation,
    super.key,
  });

  final FarmData farm;
  final Locale locale;
  final bool isDark;
  final ValueChanged<Locale> onLanguageChanged;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onChangeFarmLocation;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Text(
          strings.text('settings'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 19),
        _GroupTitle(title: strings.text('farmInfo')),
        _SettingsCard(
          children: [
            _InfoRow(
              icon: Icons.landscape_outlined,
              label: strings.text('farmName'),
              value: farm.location.displayName(isArabic: strings.isArabic),
            ),
            const Divider(height: 24),
            OutlinedButton.icon(
              onPressed: onChangeFarmLocation,
              icon: const Icon(Icons.map_outlined),
              label: Text(strings.text('changeFarmLocation')),
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.square_foot_outlined,
              label: strings.text('area'),
              value: '${farm.areaHectares} ha',
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.grass_outlined,
              label: strings.text('cropType'),
              value: strings.text('wheat'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _GroupTitle(title: strings.text('language')),
        _SettingsCard(
          children: [
            RadioGroup<String>(
              groupValue: locale.languageCode,
              onChanged: (value) {
                if (value != null) onLanguageChanged(Locale(value));
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.text('english')),
                    value: 'en',
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.text('arabic')),
                    value: 'ar',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _GroupTitle(title: strings.text('appearance')),
        _SettingsCard(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.text('darkMode')),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: isDark,
              activeTrackColor: AppTheme.forest,
              onChanged: onThemeChanged,
            ),
          ],
        ),
        const SizedBox(height: 22),
        _GroupTitle(title: strings.text('dataAndPrivacy')),
        _SettingsCard(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: AppTheme.forest),
                const SizedBox(width: 12),
                Expanded(child: Text(strings.text('settingsNote'))),
              ],
            ),
            const Divider(height: 25),
            Text(
              strings.text('about'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              strings.text('aboutBody'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mutedInk,
                height: 1.4,
              ),
            ),
            const Divider(height: 25),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TeamPage(),
                ),
              ),
              icon: const Icon(Icons.people_alt_outlined),
              label: Text(strings.text('meetTheTeam')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 4, bottom: 9),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppTheme.forest),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    ],
  );
}
