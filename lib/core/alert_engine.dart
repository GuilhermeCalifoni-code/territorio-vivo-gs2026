import '../models/territory_models.dart';

/// Heurísticas transparentes e testáveis. Não são modelos calibrados de risco,
/// não estimam danos nem recomendam decisões automáticas de alto impacto.
class AlertEngine {
  static List<TerritorialAlert> evaluate({
    required WeatherSnapshot weather,
    required double rainThresholdMm,
    required double heatThresholdC,
    DateTime? now,
  }) {
    final alerts = <TerritorialAlert>[];
    final next6 = weather.hourly.take(6).toList();
    final next24 = weather.hourly.take(24).toList();
    final totalRain = next6.fold<double>(0, (sum, hour) => sum + hour.rainMm);
    final maxChance = next6.fold<double>(0, (max, hour) => hour.rainChancePct > max ? hour.rainChancePct : max);
    final maxTemp = next24.fold<double>(-100, (max, hour) => hour.temperatureC > max ? hour.temperatureC : max);
    final stale = (now ?? DateTime.now()).difference(weather.fetchedAt) > const Duration(hours: 6);
    final isDemo = weather.origin == DataOrigin.synthetic;

    if (next6.length >= 6 && totalRain >= rainThresholdMm) {
      alerts.add(TerritorialAlert(
        id: 'rain', category: 'Clima', title: 'Acúmulo de chuva previsto',
        explanation: 'A soma da precipitação prevista para as próximas 6 horas ultrapassa o limite definido pelo usuário.',
        evidence: '${totalRain.toStringAsFixed(1)} mm previstos em 6h; pico de probabilidade de chuva de ${maxChance.toStringAsFixed(0)}%; limite de ${rainThresholdMm.toStringAsFixed(0)} mm.',
        limitations: 'Previsões podem mudar e não indicam alagamento para um endereço específico. Sem dados de drenagem, relevo, rios ou validação local. A probabilidade de chuva não é a probabilidade de inundação.${isDemo ? ' Cenário totalmente sintético.' : ''}',
        recommendedAction: 'Revisar boletins da Defesa Civil e medições locais antes de qualquer decisão operacional.',
        methodology: 'Regra: soma das próximas 6 precipitações horárias ≥ limiar escolhido. A probabilidade vem da previsão, não é a confiança estatística desta regra.',
        severity: totalRain >= rainThresholdMm * 1.7 ? AlertSeverity.high : AlertSeverity.medium,
        confidence: isDemo || stale ? AlertConfidence.low : maxChance >= 75 ? AlertConfidence.moderate : AlertConfidence.low,
        synthetic: isDemo,
      ));
    }
    if (next24.length >= 12 && maxTemp >= heatThresholdC) {
      alerts.add(TerritorialAlert(
        id: 'heat', category: 'Clima', title: 'Temperatura elevada prevista',
        explanation: 'A temperatura horária prevista supera o limite de atenção configurado.',
        evidence: 'Máxima prevista ${maxTemp.toStringAsFixed(1)} °C nas próximas 24h; limite de ${heatThresholdC.toStringAsFixed(0)} °C.',
        limitations: 'Não considera índice de calor individual, ilha de calor por bairro ou vulnerabilidades de saúde. Não substitui alertas oficiais.${isDemo ? ' Dados demonstrativos.' : ''}',
        recommendedAction: 'Consultar orientações oficiais e considerar campanhas preventivas após avaliação técnica.',
        methodology: 'Regra: maior temperatura prevista em até 24 horas ≥ limite configurável; confiança qualitativa, não probabilística.',
        severity: maxTemp >= heatThresholdC + 3 ? AlertSeverity.high : AlertSeverity.medium,
        confidence: isDemo || stale ? AlertConfidence.low : AlertConfidence.moderate,
        synthetic: isDemo,
      ));
    }
    final waterGrowth = DemoTerritorySeries.waterChangePct;
    if (waterGrowth > 15) {
      alerts.add(TerritorialAlert(
        id: 'water', category: 'Recursos', title: 'Tendência de consumo acima da referência',
        explanation: 'O índice ilustrativo de consumo da segunda semana supera a média da primeira.',
        evidence: 'Variação média simulada de +${waterGrowth.toStringAsFixed(1)}% entre duas semanas; regra de atenção acima de 15%.',
        limitations: 'Série fictícia, sem medidores, sazonalidade ou representatividade. Não comprova desperdício de água na cidade.',
        recommendedAction: 'Conferir séries reais de abastecimento, leituras e contexto sazonal antes de priorizar ações.',
        methodology: 'Média dos índices dos últimos 7 registros / média dos 7 anteriores − 1; limiar sintético de 15%.',
        severity: AlertSeverity.medium, confidence: AlertConfidence.low, synthetic: true,
      ));
    }
    final serviceGrowth = DemoTerritorySeries.serviceGrowthPct;
    if (serviceGrowth > 40) {
      alerts.add(TerritorialAlert(
        id: 'services', category: 'Serviços', title: 'Demanda urbana em aceleração',
        explanation: 'Uma série sintética de solicitações mostra aumento relativo à referência inicial.',
        evidence: 'Última semana: ${DemoTerritorySeries.serviceRequests.last.toStringAsFixed(0)} solicitações fictícias; +${serviceGrowth.toStringAsFixed(1)}% contra a média das primeiras 3 semanas.',
        limitations: 'Números demonstrativos, sem registros oficiais. Não implicam aumento real de demanda em São Paulo.',
        recommendedAction: 'Validar a tendência em bases municipais e planejar a alocação somente após revisão humana.',
        methodology: 'Regra: último valor / média dos primeiros 3 valores − 1; alerta se crescimento > 40%.',
        severity: AlertSeverity.medium, confidence: AlertConfidence.low, synthetic: true,
      ));
    }
    return alerts;
  }
}
