import 'package:flutter_test/flutter_test.dart';
import 'package:territorio_vivo/data/weather_api.dart';
import 'package:territorio_vivo/models/territory_models.dart';

void main() {
  test('Converte resposta Open-Meteo em previsão horária utilizável', () {
    final data = {
      'current': {
        'time': '2026-11-15T12:15',
        'temperature_2m': 29.3,
        'relative_humidity_2m': 62,
        'precipitation': 0,
        'wind_speed_10m': 9.5,
      },
      'hourly': {
        'time': ['2026-11-15T12:00', '2026-11-15T13:00'],
        'temperature_2m': [29.3, 30.2],
        'precipitation': [1.4, 2.3],
        'precipitation_probability': [56, 76],
        'relative_humidity_2m': [62, 60],
      },
    };
    final snapshot = WeatherApi.parse(data, now: DateTime(2026, 11, 15, 12));
    expect(snapshot.origin, DataOrigin.live);
    expect(snapshot.currentTemperatureC, 29.3);
    expect(snapshot.hourly.length, 2);
    expect(snapshot.hourly.first.time, DateTime(2026, 11, 15, 12));
    expect(snapshot.hourly.last.rainChancePct, 76);
  });
}
