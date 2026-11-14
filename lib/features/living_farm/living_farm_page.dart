import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/farm_data.dart';
import '../../shared/widgets/landscape_widgets.dart';

class LivingFarmPage extends StatelessWidget {
  const LivingFarmPage({
    required this.farm,
    required this.onOpenInsights,
    super.key,
  });

  final FarmData farm;
  final VoidCallback onOpenInsights;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final southMoisture = farm.zones.last.moisturePercent;
    final isStressed = southMoisture < 35;
    final isHot = farm.temperatureC >= 34;
    final statusKey = isStressed
        ? 'stress'
        : isHot
        ? 'heat'
        : 'calm';
    final statusColor = isStressed || isHot ? AppTheme.coral : AppTheme.forest;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
      children: [
        Text(
          strings.text('farmName'),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.forest,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                strings.text('goodMorning'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),
            ),
            const DemoBadge(),
          ],
        ),
        const SizedBox(height: 17),
        AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: statusColor.withValues(alpha: .14)),
          ),
          child: Row(
            children: [
              Icon(
                isStressed ? Icons.water_drop_rounded : Icons.spa_rounded,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.text('fieldStatus').toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.text(statusKey),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${farm.temperatureC}°',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                strings.text('zones'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              strings.text('tapZone'),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppTheme.mutedInk),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FarmLandscape(
          zones: farm.zones,
          onZoneSelected: (index) => _showZone(context, farm.zones[index]),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: MiniMetric(
                label: strings.text('soil'),
                value: '$southMoisture%',
                icon: Icons.water_drop_outlined,
                accent: isStressed ? AppTheme.coral : AppTheme.forest,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MiniMetric(
                label: strings.text('humidity'),
                value: '${farm.humidityPercent}%',
                icon: Icons.air_rounded,
                accent: AppTheme.sage,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MiniMetric(
                label: strings.text('rain'),
                value: '${farm.rainProbability}%',
                icon: Icons.cloud_outlined,
                accent: AppTheme.coral,
              ),
            ),
          ],
        ),
        const SizedBox(height: 23),
        SectionHeading(
          strings.text('recommendation'),
          trailing: Icon(Icons.auto_awesome, color: AppTheme.coral, size: 19),
        ),
        _RecommendationCard(onTap: onOpenInsights),
        const SizedBox(height: 22),
        SectionHeading(
          strings.text('sectionExplore'),
          trailing: TextButton(
            onPressed: onOpenInsights,
            child: Text(strings.text('seeAll')),
          ),
        ),
        _ExploreStrip(onTap: onOpenInsights),
        const SizedBox(height: 15),
        Center(
          child: Text(
            strings.text('demoNotice'),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppTheme.mutedInk),
          ),
        ),
      ],
    );
  }

  void _showZone(BuildContext context, FarmZone zone) {
    final strings = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.text('zoneDetail'),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppTheme.mutedInk),
            ),
            const SizedBox(height: 5),
            Text(
              strings.text(zone.nameKey),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: MiniMetric(
                    label: strings.text('soil'),
                    value: '${zone.moisturePercent}%',
                    icon: Icons.water_drop_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MiniMetric(
                    label: strings.text('ndvi'),
                    value: zone.ndvi.toStringAsFixed(2),
                    icon: Icons.eco_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MiniMetric(
                    label: strings.text('cropHealth'),
                    value: '${zone.healthPercent}%',
                    icon: Icons.favorite_border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${strings.text('cropType')}: '
              '${strings.text(zone.cropNameKey)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Material(
      color: AppTheme.deepForest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(19),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.water_drop_outlined, color: Color(0xFFB5D4A8)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.text('recommendationTitle'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      strings.text('recommendationBody'),
                      style: const TextStyle(
                        color: Color(0xFFD8E5DC),
                        height: 1.4,
                        fontSize: 12,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.text('action'),
                      style: const TextStyle(
                        color: Color(0xFFB5D4A8),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFB5D4A8),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreStrip extends StatelessWidget {
  const _ExploreStrip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    const items = [
      ('satellite', Icons.satellite_alt_outlined),
      ('climate', Icons.wb_sunny_outlined),
      ('crop', Icons.grass_rounded),
    ];
    return SizedBox(
      height: 93,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 130,
            child: Material(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(item.$2, color: AppTheme.forest, size: 20),
                      Text(
                        strings.text(item.$1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
