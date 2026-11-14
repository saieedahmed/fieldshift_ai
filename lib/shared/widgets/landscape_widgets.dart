import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/farm_data.dart';

class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.coral.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        strings.text('demo').toUpperCase(),
        style: const TextStyle(
          color: AppTheme.coral,
          fontSize: 9,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class FarmLandscape extends StatelessWidget {
  const FarmLandscape({
    required this.zones,
    required this.onZoneSelected,
    super.key,
  });

  final List<FarmZone> zones;
  final ValueChanged<int> onZoneSelected;

  @override
  Widget build(BuildContext context) {
    final labels = zones
        .map((zone) => AppLocalizations.of(context).text(zone.nameKey))
        .toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: 1.46,
        child: LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final point = details.localPosition;
              final index = point.dy / constraints.maxHeight > 0.56
                  ? 2
                  : point.dx / constraints.maxWidth > 0.55
                  ? 1
                  : 0;
              onZoneSelected(index.clamp(0, zones.length - 1));
            },
            child: CustomPaint(
              painter: _LandscapePainter(
                labels: labels,
                moisture: zones.map((zone) => zone.moisturePercent).toList(),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  _LandscapePainter({required this.labels, required this.moisture});

  final List<String> labels;
  final List<int> moisture;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFDCE6D5),
    );

    final fields = <Path>[
      Path()
        ..moveTo(w * .04, h * .10)
        ..quadraticBezierTo(w * .28, -h * .02, w * .53, h * .12)
        ..lineTo(w * .49, h * .54)
        ..quadraticBezierTo(w * .23, h * .62, w * .02, h * .48)
        ..close(),
      Path()
        ..moveTo(w * .59, h * .12)
        ..quadraticBezierTo(w * .79, h * .03, w * .98, h * .14)
        ..lineTo(w * .96, h * .49)
        ..quadraticBezierTo(w * .76, h * .60, w * .55, h * .52)
        ..close(),
      Path()
        ..moveTo(w * .02, h * .62)
        ..quadraticBezierTo(w * .25, h * .51, w * .49, h * .63)
        ..lineTo(w * .48, h * .96)
        ..quadraticBezierTo(w * .20, h * 1.02, w * .02, h * .90)
        ..close(),
    ];

    final colors = [
      const Color(0xFF779A70),
      const Color(0xFF9FB48C),
      moisture.length > 2 && moisture[2] < 35
          ? const Color(0xFFD79A65)
          : const Color(0xFF648A60),
    ];
    for (var i = 0; i < fields.length; i++) {
      canvas.drawPath(fields[i], Paint()..color = colors[i]);
      canvas.save();
      canvas.clipPath(fields[i]);
      final rowPaint = Paint()
        ..color = Colors.white.withValues(alpha: .24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;
      for (var line = -5; line < 16; line++) {
        final x = w * (line * .075);
        final row = Path()
          ..moveTo(x, h * .04)
          ..cubicTo(x + w * .12, h * .20, x - w * .05, h * .35, x + w * .11, h);
        canvas.drawPath(row, rowPaint);
      }
      canvas.restore();
    }

    final pathPaint = Paint()
      ..color = const Color(0xFFF7F5EE).withValues(alpha: .90)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    final paths = Path()
      ..moveTo(w * .51, h * .02)
      ..cubicTo(w * .46, h * .30, w * .53, h * .61, w * .49, h * 1.02)
      ..moveTo(w * .03, h * .56)
      ..cubicTo(w * .29, h * .52, w * .68, h * .58, w * .99, h * .53);
    canvas.drawPath(paths, pathPaint);

    final markers = [
      Offset(w * .28, h * .32),
      Offset(w * .77, h * .31),
      Offset(w * .27, h * .77),
    ];
    for (var i = 0; i < markers.length && i < labels.length; i++) {
      final center = markers[i];
      canvas.drawCircle(
        center,
        20,
        Paint()..color = Colors.white.withValues(alpha: .85),
      );
      canvas.drawCircle(
        center,
        14,
        Paint()
          ..color = i == 2 && moisture[i] < 35
              ? AppTheme.coral
              : AppTheme.forest,
      );
      final value = moisture.length > i ? '${moisture[i]}%' : '';
      final text = TextPainter(
        text: TextSpan(
          text: value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
      final label = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: w * .27);
      final labelCenter = Offset(center.dx, center.dy + 34);
      final labelRect = Rect.fromCenter(
        center: labelCenter,
        width: label.width + 12,
        height: label.height + 6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(9)),
        Paint()..color = AppTheme.deepForest.withValues(alpha: .82),
      );
      label.paint(canvas, Offset(labelRect.left + 6, labelRect.top + 3));
    }

    final title = TextPainter(
      text: TextSpan(
        text: 'MENOUFIA  ·  EGYPT',
        style: TextStyle(
          color: AppTheme.deepForest.withValues(alpha: .7),
          fontSize: 9,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(canvas, Offset(14, h - 22));
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) =>
      oldDelegate.labels != labels || oldDelegate.moisture != moisture;
}

class MiniMetric extends StatelessWidget {
  const MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.accent = AppTheme.forest,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: accent),
          const SizedBox(height: 11),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppTheme.mutedInk),
          ),
        ],
      ),
    );
  }
}

class TrendChart extends StatelessWidget {
  const TrendChart({required this.values, super.key});

  final List<double> values;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 118,
    width: double.infinity,
    child: CustomPaint(
      painter: _TrendPainter(
        values: values,
        lineColor: Theme.of(context).colorScheme.primary,
        fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
      ),
    ),
  );
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final minValue = values.reduce((a, b) => a < b ? a : b) - 2;
    final maxValue = values.reduce((a, b) => a > b ? a : b) + 2;
    final points = List.generate(values.length, (index) {
      final x = size.width * index / (values.length - 1);
      final y =
          size.height -
          ((values[index] - minValue) / (maxValue - minValue)) *
              (size.height - 16) -
          8;
      return Offset(x, y);
    });
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final middle = (previous.dx + current.dx) / 2;
      line.cubicTo(
        middle,
        previous.dy,
        middle,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = fillColor);
    canvas.drawPath(
      line,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      points.last,
      5,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.lineColor != lineColor;
}
