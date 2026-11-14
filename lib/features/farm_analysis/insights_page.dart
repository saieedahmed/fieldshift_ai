import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/farm_data.dart';
import '../../shared/widgets/landscape_widgets.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({required this.farm, super.key});

  final FarmData farm;

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  int _selected = 0;
  static const _tabs = ['overview', 'satellite', 'climate', 'crop'];

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Text(
          strings.text('analysisTitle'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          strings.text('demoNotice'),
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppTheme.mutedInk),
        ),
        const SizedBox(height: 4),
        Text(
          '${strings.text('farmLocationLabel')}: ${widget.farm.location.displayName(isArabic: strings.isArabic)}',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppTheme.mutedInk),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => ChoiceChip(
              label: Text(strings.text(_tabs[index])),
              selected: _selected == index,
              onSelected: (_) => setState(() => _selected = index),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _selected == 0
              ? _overview(context)
              : _selected == 1
              ? _satellite(context)
              : _selected == 2
              ? _climate(context)
              : _crop(context),
        ),
      ],
    );
  }

  Widget _overview(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.42,
          children: [
            MiniMetric(
              label: strings.text('cropHealth'),
              value: '84%',
              icon: Icons.favorite_border,
            ),
            MiniMetric(
              label: strings.text('ndvi'),
              value: '0.71',
              icon: Icons.eco_outlined,
              accent: AppTheme.sage,
            ),
            MiniMetric(
              label: strings.text('soil'),
              value: '37%',
              icon: Icons.water_drop_outlined,
              accent: AppTheme.coral,
            ),
            MiniMetric(
              label: strings.text('temperature'),
              value: '${widget.farm.temperatureC}°C',
              icon: Icons.thermostat_outlined,
              accent: AppTheme.coral,
            ),
          ],
        ),
        const SizedBox(height: 18),
        SectionHeading(strings.text('risk')),
        _RiskTile(
          icon: Icons.wb_sunny_outlined,
          title: strings.text('riskHeat'),
          body: strings.text('riskHeatBody'),
          color: AppTheme.coral,
        ),
        const SizedBox(height: 10),
        _RiskTile(
          icon: Icons.water_drop_outlined,
          title: strings.text('riskWater'),
          body: strings.text('riskWaterBody'),
          color: const Color(0xFF7C9C87),
        ),
      ],
    );
  }

  Widget _satellite(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ObservationCard(farm: widget.farm),
        const SizedBox(height: 16),
        SectionHeading(strings.text('observations')),
        for (final zone in widget.farm.zones) ...[
          _ZoneObservation(zone: zone),
          const SizedBox(height: 9),
        ],
        const SizedBox(height: 8),
        _InfoCard(
          title: strings.text('ndviMeaning'),
          body: strings.text('ndviBody'),
          icon: Icons.info_outline,
        ),
      ],
    );
  }

  Widget _climate(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, color: AppTheme.coral),
                  const SizedBox(width: 9),
                  Text(
                    strings.text('weather'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                '${widget.farm.temperatureC}°',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(strings.text('weatherNote')),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ClimateValue(
                      icon: Icons.air,
                      label: strings.text('humidity'),
                      value: '${widget.farm.humidityPercent}%',
                    ),
                  ),
                  Expanded(
                    child: _ClimateValue(
                      icon: Icons.cloud_outlined,
                      label: strings.text('rain'),
                      value: '${widget.farm.rainProbability}%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionHeading(strings.text('trend')),
        _ChartCard(farm: widget.farm),
        const SizedBox(height: 12),
        Text(
          strings.text('demoNotice'),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _crop(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CropSummary(farm: widget.farm),
        const SizedBox(height: 16),
        SectionHeading(strings.text('risk')),
        _RiskTile(
          icon: Icons.grass_outlined,
          title: strings.text('healthy'),
          body: strings.text('growing'),
          color: AppTheme.forest,
        ),
        const SizedBox(height: 10),
        _RiskTile(
          icon: Icons.thermostat_outlined,
          title: strings.text('riskHeat'),
          body: strings.text('riskHeatBody'),
          color: AppTheme.coral,
        ),
      ],
    );
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
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
      ],
    ),
  );
}

class _ObservationCard extends StatelessWidget {
  const _ObservationCard({required this.farm});
  final FarmData farm;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      height: 185,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB6C7A6), Color(0xFF597D5C)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            bottom: -34,
            child: Icon(
              Icons.spa_outlined,
              size: 170,
              color: Colors.white.withValues(alpha: .18),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.satellite_alt_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strings.text('satellite'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const DemoBadge(),
                ],
              ),
              const Spacer(),
              Text(
                '0.71',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                strings.text('ndvi'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                strings.text('observationNote'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .85),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZoneObservation extends StatelessWidget {
  const _ZoneObservation({required this.zone});
  final FarmZone zone;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppTheme.forest),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strings.text(zone.nameKey),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            zone.ndvi.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: LinearProgressIndicator(
              value: zone.ndvi,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              color: zone.ndvi > .7 ? AppTheme.forest : AppTheme.coral,
              backgroundColor: AppTheme.paleSage,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppTheme.paleSage.withValues(alpha: .65),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.forest),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(
                body,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.farm});
  final FarmData farm;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.text('week'),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.mutedInk),
          ),
          const SizedBox(height: 16),
          TrendChart(values: farm.temperatureHistory),
          Text(
            '${farm.temperatureHistory.first.toInt()}°  ·  ${farm.temperatureHistory.last.toInt()}°C',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ClimateValue extends StatelessWidget {
  const _ClimateValue({
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
      Icon(icon, color: AppTheme.forest, size: 18),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    ],
  );
}

class _CropSummary extends StatelessWidget {
  const _CropSummary({required this.farm});
  final FarmData farm;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.paleSage,
                ),
                child: const Icon(Icons.grass_rounded, color: AppTheme.forest),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.text('wheat'),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.text('growing'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Text(
                '84%',
                style: TextStyle(
                  color: AppTheme.forest,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: .84,
              minHeight: 9,
              color: AppTheme.forest,
              backgroundColor: AppTheme.paleSage,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              strings.text('updating'),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
