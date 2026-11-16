import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/app_controller.dart';
import '../../models/territory_models.dart';
import '../../widgets/common.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    return PageContent(children: [
      const Headline('Alertas fundamentados', subtitle: 'Sinalizações preventivas sujeitas à revisão humana'),
      DataSourceBanner(origin: state.weather.origin, timestamp: state.weather.fetchedAt),
      const SectionTitle('Alertas ativos'),
      if (state.alerts.isEmpty) const EmptyState(message: 'Nenhum limite ultrapassado. Não significa ausência de riscos.', icon: Icons.check_circle_outline)
      else ...state.alerts.map((alert) => AlertTile(
        alert: alert,
        onTap: () => context.pushNamed('alert-detail', pathParameters: {'id': alert.id}),
      )),
      const SectionTitle('Como funcionam'),
      const NoteBox('Alertas baseados em regras transparentes. Níveis de confiança são avaliações QUALITATIVAS, não probabilidades estatisticamente calibradas. Valores e limites podem ser revistos em Configurações.'),
      Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(
        onPressed: () => context.pushNamed('settings'), icon: const Icon(Icons.tune),
        label: const Text('Ajustar limiares'),
      )),
      const NoteBox('DECISÃO HUMANA OBRIGATÓRIA: nunca usar este projeto para determinar evacuações, suspender serviços, distribuir recursos ou realizar outras ações de alto impacto automaticamente.', icon: Icons.verified_user_outlined),
    ]);
  }
}

class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(appProvider).alerts;
    TerritorialAlert? selected;
    for (final alert in alerts) {
      if (alert.id == id) { selected = alert; break; }
    }
    if (selected == null) return const PageContent(children: [
      Headline('Alerta indisponível'),
      EmptyState(message: 'Este alerta não está mais ativo após a atualização dos dados ou dos limites.'),
    ]);
    final alert = selected;
    final highlight = alert.severity == AlertSeverity.high ? AppPalette.rose : AppPalette.amber;
    return PageContent(children: [
      Headline(alert.title, subtitle: '${alert.category} · ${alert.severityLabel}'),
      SurfacePanel(child: Row(children: [
        Icon(Icons.warning_amber_rounded, color: highlight),
        const SizedBox(width: 10),
        Expanded(child: Text('${alert.severityLabel} · Confiança ${alert.confidenceLabel}', style: const TextStyle(fontWeight: FontWeight.bold))),
      ])),
      if (alert.synthetic) ...[
        const SizedBox(height: 12),
        const NoteBox('Este alerta utiliza valores de demonstração, não uma leitura municipal real.', icon: Icons.science_outlined),
      ],
      const SectionTitle('Por que este alerta apareceu?'),
      SurfacePanel(child: Text(alert.explanation)),
      const SectionTitle('Evidências observadas'),
      SurfacePanel(child: Text(alert.evidence)),
      const SectionTitle('Regra de cálculo'),
      SurfacePanel(child: Text(alert.methodology)),
      const SectionTitle('Limitações e vieses'),
      SurfacePanel(child: Text(alert.limitations)),
      const SectionTitle('Ação sugerida para avaliação'),
      SurfacePanel(child: Text(alert.recommendedAction)),
      const NoteBox('ESTE ALERTA É UM APOIO ANALÍTICO. Não substitui a Defesa Civil, órgãos municipais, análise técnica nem avaliação humana. A confiança informada não é uma taxa de acerto medida.', icon: Icons.gavel_outlined),
      FilledButton.icon(onPressed: () => context.go('/alerts'), icon: const Icon(Icons.arrow_back), label: const Text('Voltar aos alertas')),
    ]);
  }
}
