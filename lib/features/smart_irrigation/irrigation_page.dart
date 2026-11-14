import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/farm_data.dart';
import '../../shared/widgets/landscape_widgets.dart';

class IrrigationPage extends StatefulWidget {
  const IrrigationPage({required this.farm, super.key});

  final FarmData farm;

  @override
  State<IrrigationPage> createState() => _IrrigationPageState();
}

class _IrrigationPageState extends State<IrrigationPage> {
  bool _scheduled = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Text(
          strings.text('water'),
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
        const SizedBox(height: 17),
        Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            color: AppTheme.deepForest,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.water_drop_outlined,
                    color: Color(0xFFB5D4A8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.text('soil'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const DemoBadge(),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '37%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      strings.text('healthy'),
                      style: const TextStyle(color: Color(0xFFB5D4A8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  value: .37,
                  minHeight: 8,
                  color: Color(0xFFB5D4A8),
                  backgroundColor: Color(0xFF3B5E4A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        Row(
          children: [
            Expanded(
              child: MiniMetric(
                label: strings.text('waterUse'),
                value: '${widget.farm.waterUseCubicMeters} m³',
                icon: Icons.water_outlined,
                accent: AppTheme.forest,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MiniMetric(
                label: strings.text('area'),
                value: '${widget.farm.areaHectares} ha',
                icon: Icons.landscape_outlined,
                accent: AppTheme.sage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionHeading(strings.text('schedule')),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: const BoxDecoration(
                  color: AppTheme.paleSage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppTheme.forest,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.text('nextIrrigation'),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.text('tomorrow'),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Icon(
                _scheduled ? Icons.check_circle : Icons.circle_outlined,
                color: _scheduled ? AppTheme.forest : AppTheme.sage,
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        FilledButton.icon(
          onPressed: () {
            setState(() => _scheduled = !_scheduled);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  strings.text(_scheduled ? 'scheduled' : 'startSchedule'),
                ),
              ),
            );
          },
          icon: Icon(_scheduled ? Icons.check : Icons.add_task),
          label: Text(strings.text(_scheduled ? 'scheduled' : 'startSchedule')),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: AppTheme.forest,
          ),
        ),
        const SizedBox(height: 24),
        SectionHeading(strings.text('waterSaved')),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EDE2),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.tips_and_updates_outlined,
                color: AppTheme.forest,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.text('waterSavedBody'),
                  style: const TextStyle(height: 1.45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final zone in widget.farm.zones) ...[
          _MoistureRow(zone: zone),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _MoistureRow extends StatelessWidget {
  const _MoistureRow({required this.zone});
  final FarmZone zone;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final color = zone.moisturePercent < 35 ? AppTheme.coral : AppTheme.forest;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              strings.text(zone.nameKey),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            width: 76,
            child: LinearProgressIndicator(
              value: zone.moisturePercent / 100,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              color: color,
              backgroundColor: AppTheme.paleSage,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${zone.moisturePercent}%',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
