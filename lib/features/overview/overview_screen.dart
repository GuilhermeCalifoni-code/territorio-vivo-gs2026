import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/app_controller.dart';
import '../../models/territory_models.dart';
import '../../widgets/common.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final weather = state.weather;
    final alerts = state.alerts;
    return RefreshIndicator(
      onRefresh: () => ref.read(appProvider.notifier).refreshWeather(),
      child: PageContent(children: [
        Headline('São Paulo em perspectiva', subtitle: 'Indicadores territoriais · ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
        DataSourceBanner(origin: weather.origin, timestamp: weather.fetchedAt),
        if (state.isLoading) ...[const SizedBox(height: 12), const LinearProgressIndicator()],
        if (state.errorMessage != null) ...[
          NoteBox(state.errorMessage!, icon: Icons.wifi_off_outlined),
          Align(alignment: Alignment.centerRight, child: TextButton.icon(
            onPressed: () => ref.read(appProvider.notifier).refreshWeather(),
            icon: const Icon(Icons.refresh), label: const Text('Tentar novamente'),
          )),
        ],
        const SectionTitle('Visão geral'),
        MetricGrid(cards: [
          MetricCard(icon: Icons.thermostat_outlined, label: 'Temperatura atual', value: '${weather.currentTemperatureC.toStringAsFixed(1)} °C', detail: 'Centro de São Paulo', tint: AppPalette.blue),
          MetricCard(icon: Icons.water_drop_outlined, label: 'Índice consumo', value: DemoTerritorySeries.waterIndex.last.toStringAsFixed(0), detail: 'Dados sintéticos · base ilustrativa', tint: AppPalette.teal),
          MetricCard(icon: Icons.campaign_outlined, label: 'Solicitações', value: DemoTerritorySeries.serviceRequests.last.toStringAsFixed(0), detail: 'Semana fictícia · dados simulados', tint: AppPalette.amber),
          MetricCard(icon: Icons.crisis_alert_outlined, label: 'Alertas para revisão', value: '${alerts.length}', detail: 'Indicador de prevenção potencial', tint: AppPalette.rose),
        ]),
        const SectionTitle('Painéis territoriais'),
        _DashboardLink(icon: Icons.cloud_outlined, title: 'Clima & chuvas', subtitle: 'Histórico previsto, temperatura e precipitação', onTap: () => context.go('/climate')),
        _DashboardLink(icon: Icons.water_drop_outlined, title: 'Recursos hídricos', subtitle: 'Índice de consumo simulado e tendências', onTap: () => context.go('/resources')),
        _DashboardLink(icon: Icons.apartment_outlined, title: 'Serviços urbanos', subtitle: 'Demanda sintética e ocorrências locais', onTap: () => context.go('/services')),
        SectionTitle('Alertas que exigem atenção', action: TextButton(onPressed: () => context.go('/alerts'), child: const Text('Ver todos'))),
        if (alerts.isEmpty) const EmptyState(message: 'Sem alertas ativos para os limites definidos.')
        else ...alerts.take(2).map((a) => AlertTile(alert: a, onTap: () => context.pushNamed('alert-detail', pathParameters: {'id': a.id}))),
        const NoteBox('Indicador de benefício social (proxy): quantidade de sinalizações preventivas disponibilizadas à revisão humana. Não representa incidentes evitados nem benefícios comprovados. Alertas não autorizam ações automáticas.'),
      ]),
    );
  }
}

class _DashboardLink extends StatelessWidget {
  const _DashboardLink({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: SurfacePanel(padding: EdgeInsets.zero, child: InkWell(
      borderRadius: BorderRadius.circular(20), onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [
        Icon(icon, color: AppPalette.teal, size: 28),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3), Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
        const Icon(Icons.arrow_forward_ios_rounded, size: 15),
      ])),
    )),
  );
}
