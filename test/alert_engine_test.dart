import 'package:flutter_test/flutter_test.dart';
import 'package:territorio_vivo/core/alert_engine.dart';
import 'package:territorio_vivo/models/territory_models.dart';

void main() {
  test('Cenário sintético gera 4 alertas fundamentados', () {
    final alerts = AlertEngine.evaluate(
      weather: WeatherSnapshot.demonstration(DateTime.now()),
      rainThresholdMm: 18,
      heatThresholdC: 33,
    );
    expect(alerts.map((a) => a.id).toSet(), containsAll({'rain', 'heat', 'water', 'services'}));
    for (final alert in alerts) {
      expect(alert.evidence, isNotEmpty);
      expect(alert.limitations, isNotEmpty);
      expect(alert.methodology, isNotEmpty);
      expect(alert.recommendedAction, isNotEmpty);
      expect(alert.confidence, AlertConfidence.low);
    }
  });

  test('Alterar limiares altera dinamicamente alertas climáticos', () {
    final snapshot = WeatherSnapshot.demonstration(DateTime.now());
    final alerts = AlertEngine.evaluate(
      weather: snapshot, rainThresholdMm: 200, heatThresholdC: 50,
    );
    expect(alerts.any((a) => a.id == 'rain'), false);
    expect(alerts.any((a) => a.id == 'heat'), false);
    expect(alerts.map((a) => a.id), containsAll(['water', 'services']));
  });

  test('Série real sem chuva não gera alerta climático de chuva', () {
    final now = DateTime.now();
    final snapshot = WeatherSnapshot(
      fetchedAt: now,
      currentTemperatureC: 23,
      currentHumidityPct: 50,
      currentPrecipitationMm: 0,
      currentWindKmh: 8,
      origin: DataOrigin.live,
      hourly: List.generate(25, (i) => HourlyWeather(
        time: now.add(Duration(hours: i)),
        temperatureC: 22,
        rainMm: 0,
        rainChancePct: 0,
        humidityPct: 50,
      )),
    );
    final alerts = AlertEngine.evaluate(weather: snapshot, rainThresholdMm: 18, heatThresholdC: 33);
    expect(alerts.any((a) => a.id == 'rain' || a.id == 'heat'), false);
  });

  test('Snapshot live com mais de 6h deve gerar alerta com confiança baixa', () {
    final now = DateTime(2026, 11, 15, 18);
    final snapshot = WeatherSnapshot(
      fetchedAt: now.subtract(const Duration(hours: 7)),
      currentTemperatureC: 34,
      currentHumidityPct: 80,
      currentPrecipitationMm: 4,
      currentWindKmh: 9,
      origin: DataOrigin.live,
      hourly: List.generate(24, (i) => HourlyWeather(
        time: now.add(Duration(hours: i)),
        temperatureC: 35,
        rainMm: 5,
        rainChancePct: 95,
        humidityPct: 85,
      )),
    );
    final alerts = AlertEngine.evaluate(
      weather: snapshot,
      rainThresholdMm: 18,
      heatThresholdC: 33,
      now: now,
    );
    expect(alerts.firstWhere((a) => a.id == 'rain').confidence, AlertConfidence.low);
    expect(alerts.firstWhere((a) => a.id == 'heat').confidence, AlertConfidence.low);
  });

  test('Serialização do cache preserva dados e não muda fonte silenciosamente', () {
    final source = WeatherSnapshot.demonstration(DateTime(2026, 11, 15, 10));
    final restored = WeatherSnapshot.fromJson(source.toJson());
    expect(restored.origin, DataOrigin.synthetic);
    expect(restored.hourly.length, 48);
    expect(restored.hourly[2].rainMm, source.hourly[2].rainMm);
  });
}
