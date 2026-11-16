import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/territory_models.dart';

class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.children, this.crossAxisAlignment = CrossAxisAlignment.start});
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [Column(crossAxisAlignment: crossAxisAlignment, children: children)],
        ),
      ),
    ),
  );
}

class Headline extends StatelessWidget {
  const Headline(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
      if (subtitle != null) ...[
        const SizedBox(height: 7),
        Text(subtitle!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    ]),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 12),
    child: Row(children: [
      Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
      if (action != null) action!,
    ]),
  );
}

class SurfacePanel extends StatelessWidget {
  const SurfacePanel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Material (e não Container decorado) para que ListTile, SwitchListTile e
    // InkWell dentro do painel desenhem fundo e efeito de toque corretamente.
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outline.withValues(alpha: .18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: double.infinity, child: Padding(padding: padding, child: child)),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.icon, required this.label, required this.value, this.detail = '', this.tint = AppPalette.teal});
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color tint;
  @override
  Widget build(BuildContext context) => SurfacePanel(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: tint, size: 27),
      const SizedBox(height: 13),
      Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
      if (detail.isNotEmpty) ...[const SizedBox(height: 4), Text(detail, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))],
    ],
  ));
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key, required this.cards});
  final List<Widget> cards;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final columns = box.maxWidth >= 760 ? 4 : 2;
    final width = (box.maxWidth - (columns - 1) * 10) / columns;
    return Wrap(spacing: 10, runSpacing: 10, children: cards.map((card) => SizedBox(width: width, child: card)).toList());
  });
}

class DataSourceBanner extends StatelessWidget {
  const DataSourceBanner({super.key, required this.origin, this.timestamp});
  final DataOrigin origin;
  final DateTime? timestamp;
  @override
  Widget build(BuildContext context) {
    final color = origin == DataOrigin.live ? AppPalette.teal : AppPalette.amber;
    final date = timestamp;
    final detail = date == null
        ? origin == DataOrigin.synthetic ? 'Série fixa de demonstração' : 'Atualização indisponível'
        : 'Atualização: ${DateFormat('dd/MM HH:mm').format(date)}';
    final semanticDetail = date == null
        ? origin == DataOrigin.synthetic ? 'série fixa de demonstração' : 'sem horário de coleta disponível'
        : 'última coleta ${DateFormat('dd/MM/yyyy HH:mm').format(date)}';
    return Semantics(
      label: '${origin.label}; $semanticDetail',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(13), border: Border.all(color: color.withValues(alpha: .35))),
        child: Row(children: [
          Icon(origin == DataOrigin.live ? Icons.wifi_rounded : Icons.info_outline, color: color, size: 19),
          const SizedBox(width: 9),
          Expanded(child: Text('${origin.label}\n$detail', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        ]),
      ),
    );
  }
}

class NoteBox extends StatelessWidget {
  const NoteBox(this.text, {super.key, this.icon = Icons.info_outline});
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: SurfacePanel(padding: const EdgeInsets.all(14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4, fontSize: 13))),
    ])),
  );
}

class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.values, required this.label, this.tint = AppPalette.teal, this.suffix = '', this.intervalLabels = const []});
  final List<double> values;
  final String label;
  final Color tint;
  final String suffix;
  final List<String> intervalLabels;
  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const EmptyState(message: 'Sem dados para exibir neste gráfico.');
    final top = values.reduce(math.max);
    final low = values.reduce(math.min);
    final spread = math.max(1.0, top - low);
    final minY = math.max(0.0, low - spread * .23);
    final maxY = top + spread * .27;
    return Semantics(
      label: '$label. Valores ${values.map((v) => v.toStringAsFixed(1)).join(', ')} $suffix',
      child: SurfacePanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 22),
        SizedBox(height: 210, child: LineChart(LineChartData(
          minX: 0, maxX: (values.length - 1).toDouble(), minY: minY, maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (maxY - minY) / 4),
          lineTouchData: LineTouchData(enabled: true, touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem('${spot.y.toStringAsFixed(1)} $suffix', TextStyle(color: tint, fontWeight: FontWeight.bold))).toList(),
          )),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: (maxY - minY) / 4, getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(0), style: const TextStyle(fontSize: 10)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: math.max(1.0, ((values.length - 1) / 4).ceilToDouble()), getTitlesWidget: (v, meta) {
              final i = v.round();
              if (i < 0 || i >= values.length) return const SizedBox.shrink();
              final text = intervalLabels.isNotEmpty && i < intervalLabels.length ? intervalLabels[i] : '${i + 1}';
              return Padding(padding: const EdgeInsets.only(top: 7), child: Text(text, style: const TextStyle(fontSize: 10)));
            })),
          ),
          lineBarsData: [LineChartBarData(
            spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
            isCurved: true, color: tint, barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: tint.withValues(alpha: .12)),
          )],
        ))),
      ])),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_outlined});
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SurfacePanel(child: Column(children: [
    Icon(icon, size: 38, color: Theme.of(context).colorScheme.outline),
    const SizedBox(height: 10), Text(message, textAlign: TextAlign.center),
  ]));
}

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert, required this.onTap});
  final TerritorialAlert alert;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final tint = alert.severity == AlertSeverity.high ? AppPalette.rose : AppPalette.amber;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(button: true, label: '${alert.title}. ${alert.severityLabel}. ${alert.confidenceLabel}',
        child: SurfacePanel(padding: EdgeInsets.zero, child: InkWell(
          borderRadius: BorderRadius.circular(20), onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            CircleAvatar(backgroundColor: tint.withValues(alpha: .15), child: Icon(alert.category == 'Clima' ? Icons.cloud_outlined : alert.category == 'Recursos' ? Icons.water_drop_outlined : Icons.location_city_outlined, color: tint)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(alert.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${alert.severityLabel} · Confiança ${alert.confidenceLabel}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              if (alert.synthetic) ...[const SizedBox(height: 4), const Text('SÉRIE SINTÉTICA', style: TextStyle(color: AppPalette.amber, fontSize: 10, fontWeight: FontWeight.bold))],
            ])),
            const Icon(Icons.chevron_right),
          ])),
        )),
      ),
    );
  }
}
