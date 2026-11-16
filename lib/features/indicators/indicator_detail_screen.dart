import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/app_controller.dart';
import '../../models/territory_models.dart';
import '../../widgets/common.dart';

class IndicatorDetailScreen extends ConsumerWidget {
  const IndicatorDetailScreen({super.key, required this.category, required this.metric});
  final String category;
  final String metric;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    if (category == 'climate') {
      final next = state.weather.hourly.take(6).toList();
      final sum = next.fold<double>(0, (s, v) => s + v.rainMm);
      return PageContent(children: [
        const Headline('Metodologia · Clima', subtitle: 'Precipitação acumulada e limiar de atenção'),
        DataSourceBanner(origin: state.weather.origin, timestamp: state.weather.fetchedAt),
        const SectionTitle('Cálculo de alerta de chuva'),
        SurfacePanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Soma das próximas 6 horas: ${sum.toStringAsFixed(1)} mm'),
          const SizedBox(height: 8),
          Text('Limite definido: ${state.rainThresholdMm.toStringAsFixed(1)} mm'),
          const SizedBox(height: 8),
          Text('Resultado: ${next.length >= 6 && sum >= state.rainThresholdMm ? 'atenção' : 'abaixo do limite'}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('A precipitação horária é somada sem combinar a probabilidade de chuva como se fosse risco de alagamento.'),
        ])),
        const SectionTitle('Série de entrada'),
        TrendChart(values: next.map((p) => p.rainMm).toList(), label: 'Precipitação · próximas 6 horas', suffix: 'mm'),
        const NoteBox('Fonte: Open-Meteo Forecast API quando disponível. Riscos reais dependem também de relevo, drenagem, ocupação do solo e monitoramento oficial. O cenário offline é artificial.'),
      ]);
    }
    if (category == 'resources') {
      return PageContent(children: [
        const Headline('Metodologia · Água', subtitle: 'Índice de consumo ilustrativo'),
        const DataSourceBanner(origin: DataOrigin.synthetic),
        const SectionTitle('Indicador derivado'),
        SurfacePanel(child: Text('Variação = (média dos últimos 7 pontos ÷ média dos 7 anteriores − 1) × 100 = ${DemoTerritorySeries.waterChangePct.toStringAsFixed(1)}%. Limiar de demonstração: 15%.')),
        const SectionTitle('Série sintética'),
        const TrendChart(values: DemoTerritorySeries.waterIndex, label: 'Índice artificial · 14 observações'),
        const NoteBox('Não há dados coletados de hidrômetros nem identificação de setores. A série fictícia não pode evidenciar consumo, escassez ou desperdício real.'),
      ]);
    }
    if (category == 'services') {
      return PageContent(children: [
        const Headline('Metodologia · Demanda', subtitle: 'Solicitações hipotéticas'),
        const DataSourceBanner(origin: DataOrigin.synthetic),
        const SectionTitle('Indicador derivado'),
        SurfacePanel(child: Text('Crescimento = (última semana ÷ média das três primeiras semanas − 1) × 100 = ${DemoTerritorySeries.serviceGrowthPct.toStringAsFixed(1)}%. Limiar ilustrativo: 40%.')),
        const SectionTitle('Histórico simulado'),
        const TrendChart(values: DemoTerritorySeries.serviceRequests, label: 'Solicitações fictícias · 7 semanas'),
        const NoteBox('Relatos locais enviados pelo formulário não entram neste gráfico. Não se trata de base do SP156 ou de qualquer sistema municipal.'),
      ]);
    }
    return const PageContent(children: [
      Headline('Indicador desconhecido'),
      EmptyState(message: 'Não encontramos dados para este indicador.'),
    ]);
  }
}
