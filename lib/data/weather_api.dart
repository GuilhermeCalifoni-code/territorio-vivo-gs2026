import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/territory_models.dart';

class WeatherApi {
  WeatherApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static final endpoint = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': '-23.5505',
    'longitude': '-46.6333',
    'current': 'temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m',
    'hourly': 'temperature_2m,precipitation,precipitation_probability,relative_humidity_2m',
    'forecast_days': '3',
    'timezone': 'America/Sao_Paulo',
  });

  Future<WeatherSnapshot> fetch() async {
    final response = await _client.get(endpoint).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw WeatherApiException('Servidor meteorológico: HTTP ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['error'] == true) {
      throw WeatherApiException(json['reason']?.toString() ?? 'Erro retornado pela API');
    }
    return parse(json, now: DateTime.now());
  }

  static WeatherSnapshot parse(Map<String, dynamic> body, {required DateTime now}) {
    final current = Map<String, dynamic>.from(body['current'] as Map);
    final hourly = Map<String, dynamic>.from(body['hourly'] as Map);
    // A API devolve horários locais de São Paulo sem sufixo de fuso.
    // Compare-os com o próprio horário 'current' da resposta, não com o
    // relógio do dispositivo, que pode estar em outro país/fuso.
    final apiCurrent = DateTime.parse(current['time'] as String);
    final apiCurrentHour = DateTime(apiCurrent.year, apiCurrent.month, apiCurrent.day, apiCurrent.hour);
    final times = (hourly['time'] as List).cast<String>();
    final temperatures = (hourly['temperature_2m'] as List);
    final rains = (hourly['precipitation'] as List);
    final probabilities = (hourly['precipitation_probability'] as List);
    final humidities = (hourly['relative_humidity_2m'] as List);
    final length = [times.length, temperatures.length, rains.length, probabilities.length, humidities.length]
        .reduce((a, b) => a < b ? a : b);
    if (length == 0) throw const WeatherApiException('Série temporal vazia.');
    final points = List<HourlyWeather>.generate(length, (i) => HourlyWeather(
      time: DateTime.parse(times[i]),
      temperatureC: (temperatures[i] as num?)?.toDouble() ?? 0,
      rainMm: (rains[i] as num?)?.toDouble() ?? 0,
      rainChancePct: (probabilities[i] as num?)?.toDouble() ?? 0,
      humidityPct: (humidities[i] as num?)?.toDouble() ?? 0,
    )).where((p) => !p.time.isBefore(apiCurrentHour)).toList();
    if (points.isEmpty) throw const WeatherApiException('Previsão sem horas futuras.');
    return WeatherSnapshot(
      fetchedAt: now,
      currentTemperatureC: (current['temperature_2m'] as num).toDouble(),
      currentHumidityPct: (current['relative_humidity_2m'] as num).toDouble(),
      currentPrecipitationMm: (current['precipitation'] as num).toDouble(),
      currentWindKmh: (current['wind_speed_10m'] as num).toDouble(),
      hourly: points,
      origin: DataOrigin.live,
    );
  }
  void close() => _client.close();
}

class WeatherApiException implements Exception {
  const WeatherApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
