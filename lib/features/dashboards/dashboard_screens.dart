import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/app_controller.dart';
import '../../models/territory_models.dart';
import '../../widgets/common.dart';

class ClimateScreen extends ConsumerWidget {
  const ClimateScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final weather = state.weather;
    final next = weather.hourly.take(24).toList();
    final rain6 = next.take(6).fold<double>(0, (s, p) => s + p.rainMm);
    final high = next.isEmpty ? weather.currentTemperatureC : next.map((e) => e.temperatureC).reduce((a, b) => a > b ? a : b);
    return RefreshIndicator(
      onRefresh: () => ref.read(appProvider.notifier).refreshWeather(),
      child: PageContent(children: [
        const Headline('Clima & riscos ambientais', subtitle: 'Previsão meteorológica para o centro de São Paulo'),
        DataSourceBanner(origin: weather.origin, timestamp: weather.fetchedAt),
        if (state.isLoading) const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
        if (state.errorMessage != null) NoteBox(state.errorMessage!, icon: Icons.wifi_off),
        const SizedBox(height: 15),
        MetricGrid(cards: [
          MetricCard(icon: Icons.thermostat, label: 'Agora', value: '${weather.currentTemperatureC.toStringAsFixed(1)} °C', tint: AppPalette.blue),
          MetricCard(icon: Icons.wb_sunny_outlined, label: 'Máxima · 24h', value: '${high.toStringAsFixed(1)} °C', tint: AppPalette.amber),
          MetricCard(icon: Icons.water_drop_outlined, label: 'Chuva · próximas 6h', value: '${rain6.toStringAsFixed(1)} mm', tint: AppPalette.blue),
          MetricCard(icon: Icons.air_outlined, label: 'Vento atual', value: '${weather.currentWindKmh.toStringAsFixed(0)} km/h', tint: AppPalette.teal),
        ]),
        const SectionTitle('Temperatura prevista'),
        TrendChart(values: next.map((e) => e.temperatureC).toList(), label: 'Temperatura horária · 24 horas', suffix: '°C', tint: AppPalette.amber,
            intervalLabels: next.map((e) => '${e.time.hour}h').toList()),
        const SizedBox(height: 13),
        TrendChart(values: next.map((e) => e.rainMm).toList(), label: 'Precipitação horária · 24 horas', suffix: 'mm', tint: AppPalette.blue,
            intervalLabels: next.map((e) => '${e.time.hour}h').toList()),
        const SectionTitle('Interpretação dos dados'),
        SurfacePanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Chuva: limite de atenção ${state.rainThresholdMm.toStringAsFixed(0)} mm em 6 horas.', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Calor: limite de atenção ${state.heatThresholdC.toStringAsFixed(0)} °C nas próximas 24 horas.'),
          const SizedBox(height: 15),
          OutlinedButton.icon(onPressed: () => context.pushNamed('indicator-detail', pathParameters: {'category': 'climate', 'metric': 'rain'}), icon: const Icon(Icons.insights), label: const Text('Detalhes e metodologia')),
        ])),
        const NoteBox('Fonte: Open-Meteo Forecast API (quando online). Precipitação em mm por hora; horários no fuso America/Sao_Paulo. Não há previsão de alagamentos individualizada por bairro.'),
      ]),
    );
  }
}

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final growth = DemoTerritorySeries.waterChangePct;
    return PageContent(children: [
      const Headline('Recursos & consumo', subtitle: 'Acompanhamento de tendências de consumo hídrico'),
      const DataSourceBanner(origin: DataOrigin.synthetic),
      const SizedBox(height: 15),
      MetricGrid(cards: [
        MetricCard(icon: Icons.water_drop_outlined, label: 'Índice recente', value: DemoTerritorySeries.waterIndex.last.toStringAsFixed(0), detail: 'Série com base ilustrativa', tint: AppPalette.blue),
        MetricCard(icon: Icons.trending_up_outlined, label: 'Variação quinzenal', value: '+${growth.toStringAsFixed(1)}%', detail: 'Comparação das médias de 7 dias', tint: AppPalette.amber),
      ]),
      const SectionTitle('Evolução do consumo'),
      const TrendChart(values: DemoTerritorySeries.waterIndex, label: 'Índice de consumo simulado · 14 dias', tint: AppPalette.teal, suffix: 'pontos'),
      const SectionTitle('Análise interpretável'),
      SurfacePanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Atenção para crescimento superior a 15%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text('O índice cresceu ${growth.toStringAsFixed(1)}% entre as médias das duas semanas ilustrativas. Essa é uma regra de exemplo e NÃO indica desperdício real em São Paulo.'),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: () => context.pushNamed('indicator-detail', pathParameters: {'category': 'resources', 'metric': 'water'}), icon: const Icon(Icons.insights), label: const Text('Ver cálculo e limitações')),
      ])),
      const NoteBox('Fonte: dataset sintético local, criado para avaliação acadêmica. Sem medição de hidrômetros, dados municipais ou consumo residencial. Não usar em decisões públicas reais.'),
    ]);
  }
}

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final growth = DemoTerritorySeries.serviceGrowthPct;
    return PageContent(children: [
      const Headline('Serviços urbanos', subtitle: 'Demandas locais e participação cidadã'),
      const DataSourceBanner(origin: DataOrigin.synthetic),
      const SizedBox(height: 15),
      MetricGrid(cards: [
        MetricCard(icon: Icons.construction_outlined, label: 'Demandas fictícias', value: DemoTerritorySeries.serviceRequests.last.toStringAsFixed(0), detail: 'Última semana ilustrativa', tint: AppPalette.amber),
        MetricCard(icon: Icons.trending_up_outlined, label: 'Crescimento simulado', value: '+${growth.toStringAsFixed(0)}%', detail: 'Sobre referência inicial', tint: AppPalette.rose),
        MetricCard(icon: Icons.edit_note_outlined, label: 'Meus registros', value: '${state.reports.length}', detail: 'Armazenados apenas neste aparelho', tint: AppPalette.teal),
      ]),
      const SectionTitle('Tendência de solicitações'),
      const TrendChart(values: DemoTerritorySeries.serviceRequests, label: 'Ocorrências hipotéticas · 7 semanas', tint: AppPalette.amber, suffix: 'registros'),
      const SectionTitle('Participação cidadã'),
      SurfacePanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Registrar ocorrência', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 8),
        const Text('Relate uma demanda urbana sem informar nome ou endereço. O registro é privado e não será enviado a órgãos públicos.'),
        const SizedBox(height: 14),
        FilledButton.icon(onPressed: () => context.pushNamed('report'), icon: const Icon(Icons.add), label: const Text('Nova ocorrência')),
      ])),
      SectionTitle('Ocorrências no dispositivo', action: Text('${state.reports.length} registro(s)')),
      if (state.reports.isEmpty) const EmptyState(message: 'Você ainda não registrou ocorrências. Este estado vazio é tratado pelo aplicativo.')
      else ...state.reports.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: SurfacePanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${r.category} · ${r.region}', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5), Text(r.description),
          const SizedBox(height: 5), Text('${r.createdAt.day.toString().padLeft(2, '0')}/${r.createdAt.month.toString().padLeft(2, '0')}/${r.createdAt.year}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
      )),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: () => context.pushNamed('indicator-detail', pathParameters: {'category': 'services', 'metric': 'demand'}), icon: const Icon(Icons.insights), label: const Text('Metodologia da demanda')), 
      const NoteBox('Os registros feitos no formulário não entram na série sintética do gráfico e não são enviados a serviços municipais. Para uso real seria necessária integração autorizada e validação institucional.'),
    ]);
  }
}
