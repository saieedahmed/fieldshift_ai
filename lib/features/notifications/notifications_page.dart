import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/landscape_widgets.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _cleared = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final items = [
      (
        'notificationOne',
        'notificationOneBody',
        Icons.water_drop_outlined,
        AppTheme.coral,
      ),
      (
        'notificationTwo',
        'notificationTwoBody',
        Icons.wb_sunny_outlined,
        AppTheme.coral,
      ),
      (
        'notificationThree',
        'notificationThreeBody',
        Icons.eco_outlined,
        AppTheme.forest,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('notifications')),
        actions: [
          if (!_cleared)
            IconButton(
              tooltip: strings.text('allCaughtUp'),
              onPressed: () => setState(() => _cleared = true),
              icon: const Icon(Icons.done_all),
            ),
        ],
      ),
      body: _cleared
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.forest,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(strings.text('allCaughtUp')),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const DemoBadge(),
                const SizedBox(height: 16),
                for (var index = 0; index < items.length; index++) ...[
                  _NotificationTile(
                    title: strings.text(items[index].$1),
                    body: strings.text(items[index].$2),
                    icon: items[index].$3,
                    color: items[index].$4,
                    isNew: index == 0,
                  ),
                  const SizedBox(height: 11),
                ],
              ],
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.isNew,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final bool isNew;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(21),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedInk,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (isNew)
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppTheme.coral,
              shape: BoxShape.circle,
            ),
          ),
      ],
    ),
  );
}
