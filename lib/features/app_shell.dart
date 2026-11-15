import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../data/models/farm_data.dart';
import '../data/models/farm_location.dart';
import '../data/repositories/farm_location_repository.dart';
import '../data/repositories/farm_repository.dart';
import 'ai_advisor/advisor_page.dart';
import 'farm_location/farm_location_page.dart';
import 'farm_analysis/insights_page.dart';
import 'living_farm/living_farm_page.dart';
import 'notifications/notifications_page.dart';
import 'settings/settings_page.dart';
import 'smart_irrigation/irrigation_page.dart';
import 'team/team_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.locale,
    required this.themeMode,
    required this.onLanguageChanged,
    required this.onThemeChanged,
    super.key,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final ValueChanged<Locale> onLanguageChanged;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  FarmData _farm = DemoFarmRepository().getFarm();
  final FarmLocationRepository _locationRepository =
      SharedPreferencesFarmLocationRepository();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _restoreFarmLocation();
  }

  void _openPage(int index) => setState(() => _selectedIndex = index);

  Future<void> _restoreFarmLocation() async {
    try {
      final location = await _locationRepository.load();
      if (mounted && location != null) {
        setState(() => _farm = _farm.copyWith(location: location));
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'FieldShift AI',
          context: ErrorDescription('while loading the saved farm location'),
        ),
      );
      _showLocationError();
    }
  }

  Future<void> _saveFarmLocation(FarmLocation location) async {
    await _locationRepository.save(location);
    if (mounted) setState(() => _farm = _farm.copyWith(location: location));
  }

  Future<void> _editFarmLocation() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FarmLocationPage(
          initialLocation: _farm.location,
          isArabic: widget.locale.languageCode == 'ar',
          onSave: _saveFarmLocation,
        ),
      ),
    );
  }

  void _showLocationError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final strings = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.text('locationStorageError'))),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isDark = widget.themeMode == ThemeMode.dark;
    final pages = [
      LivingFarmPage(farm: _farm, onOpenInsights: () => _openPage(1)),
      InsightsPage(farm: _farm),
      IrrigationPage(farm: _farm),
      AdvisorPage(farm: _farm, onOpenWater: () => _openPage(2)),
      SettingsPage(
        farm: _farm,
        locale: widget.locale,
        isDark: isDark,
        onLanguageChanged: widget.onLanguageChanged,
        onThemeChanged: widget.onThemeChanged,
        onChangeFarmLocation: _editFarmLocation,
      ),
    ];
    final navItems = [
      (Icons.grass_outlined, Icons.grass, 'farm'),
      (Icons.insights_outlined, Icons.insights, 'analysis'),
      (Icons.water_drop_outlined, Icons.water_drop, 'water'),
      (Icons.auto_awesome_outlined, Icons.auto_awesome, 'advisor'),
      (Icons.tune_outlined, Icons.tune, 'settings'),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.forest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FieldShift',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                Text(
                  _farm.location.displayName(isArabic: strings.isArabic),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.mutedInk,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: strings.text('meetTheTeam'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TeamPage(),
              ),
            ),
            icon: const Icon(Icons.people_outline_rounded),
          ),
          IconButton(
            tooltip: strings.text('notifications'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsPage(),
              ),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 7),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _openPage,
        destinations: [
          for (final item in navItems)
            NavigationDestination(
              icon: Icon(item.$1),
              selectedIcon: Icon(item.$2),
              label: strings.text(item.$3),
            ),
        ],
      ),
    );
  }
}
