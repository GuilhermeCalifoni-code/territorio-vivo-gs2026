import 'dart:math' as math;

/// Origem explícita dos dados exibidos no aplicativo.
enum DataOrigin { live, cache, synthetic }

extension OriginLabels on DataOrigin {
  String get label => switch (this) {
        DataOrigin.live => 'DADOS REAIS · OPEN-METEO',
        DataOrigin.cache => 'CACHE LOCAL · PODE ESTAR DESATUALIZADO',
        DataOrigin.synthetic => 'DEMONSTRAÇÃO · DADOS SINTÉTICOS',
      };
}

class HourlyWeather {
  final DateTime time;
  final double temperatureC;
  final double rainMm;
  final double rainChancePct;
  final double humidityPct;

  const HourlyWeather({
    required this.time,
    required this.temperatureC,
    required this.rainMm,
    required this.rainChancePct,
    required this.humidityPct,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) => HourlyWeather(
        time: DateTime.parse(json['time'] as String),
        temperatureC: (json['temperatureC'] as num).toDouble(),
        rainMm: (json['rainMm'] as num).toDouble(),
        rainChancePct: (json['rainChancePct'] as num).toDouble(),
        humidityPct: (json['humidityPct'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'temperatureC': temperatureC,
        'rainMm': rainMm,
        'rainChancePct': rainChancePct,
        'humidityPct': humidityPct,
      };
}

class WeatherSnapshot {
  final DateTime fetchedAt;
  final double currentTemperatureC;
  final double currentHumidityPct;
  final double currentPrecipitationMm;
  final double currentWindKmh;
  final List<HourlyWeather> hourly;
  final DataOrigin origin;

  const WeatherSnapshot({
    required this.fetchedAt,
    required this.currentTemperatureC,
    required this.currentHumidityPct,
    required this.currentPrecipitationMm,
    required this.currentWindKmh,
    required this.hourly,
    required this.origin,
  });

  WeatherSnapshot withOrigin(DataOrigin value) => WeatherSnapshot(
        fetchedAt: fetchedAt,
        currentTemperatureC: currentTemperatureC,
        currentHumidityPct: currentHumidityPct,
        currentPrecipitationMm: currentPrecipitationMm,
        currentWindKmh: currentWindKmh,
        hourly: hourly,
        origin: value,
      );

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) => WeatherSnapshot(
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        currentTemperatureC: (json['currentTemperatureC'] as num).toDouble(),
        currentHumidityPct: (json['currentHumidityPct'] as num).toDouble(),
        currentPrecipitationMm: (json['currentPrecipitationMm'] as num).toDouble(),
        currentWindKmh: (json['currentWindKmh'] as num).toDouble(),
        hourly: (json['hourly'] as List).map((e) => HourlyWeather.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        origin: DataOrigin.values.firstWhere(
          (e) => e.name == json['origin'],
          orElse: () => DataOrigin.cache,
        ),
      );

  Map<String, dynamic> toJson() => {
        'fetchedAt': fetchedAt.toIso8601String(),
        'currentTemperatureC': currentTemperatureC,
        'currentHumidityPct': currentHumidityPct,
        'currentPrecipitationMm': currentPrecipitationMm,
        'currentWindKmh': currentWindKmh,
        'hourly': hourly.map((e) => e.toJson()).toList(),
        'origin': origin.name,
      };

  /// Cenário determinístico para demonstrar todos os fluxos sem internet.
  /// Os horários são relativos à execução, nunca um boletim meteorológico real.
  factory WeatherSnapshot.demonstration([DateTime? now]) {
    final current = now ?? DateTime.now();
    final base = DateTime(current.year, current.month, current.day, current.hour);
    final hourly = List.generate(48, (index) {
      final hot = index >= 10 && index <= 15;
      final rainy = index >= 2 && index <= 5;
      return HourlyWeather(
        time: base.add(Duration(hours: index)),
        temperatureC: hot ? 33.5 + (index % 3) : 25 + 3 * math.sin(index / 5),
        rainMm: rainy ? 5.7 + (index % 2) * 1.2 : (index % 10 == 0 ? 0.4 : 0),
        rainChancePct: rainy ? 83 : 12 + (index % 5) * 5,
        humidityPct: rainy ? 88 : 58 + 15 * math.sin(index / 7),
      );
    });
    return WeatherSnapshot(
      fetchedAt: current,
      currentTemperatureC: 27.2,
      currentHumidityPct: 71,
      currentPrecipitationMm: 0,
      currentWindKmh: 11.2,
      hourly: hourly,
      origin: DataOrigin.synthetic,
    );
  }
}

class IncidentReport {
  final String id;
  final DateTime createdAt;
  final String region;
  final String category;
  final String description;

  const IncidentReport({
    required this.id,
    required this.createdAt,
    required this.region,
    required this.category,
    required this.description,
  });

  factory IncidentReport.fromJson(Map<String, dynamic> json) => IncidentReport(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        region: json['region'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'region': region,
        'category': category,
        'description': description,
      };
}

/// Série INTEIRAMENTE sintética, sem associação a números municipais reais.
class DemoTerritorySeries {
  static const waterIndex = <double>[
    106, 110, 108, 113, 112, 109, 111,
    123, 129, 135, 138, 144, 149, 155,
  ];
  static const serviceRequests = <double>[38, 44, 42, 49, 55, 61, 74];

  static double get waterChangePct {
    final baseline = waterIndex.take(7).reduce((a, b) => a + b) / 7;
    final recent = waterIndex.skip(7).reduce((a, b) => a + b) / 7;
    return (recent / baseline - 1) * 100;
  }
  static double get serviceGrowthPct {
    final baseline = serviceRequests.take(3).reduce((a, b) => a + b) / 3;
    final latest = serviceRequests.last;
    return (latest / baseline - 1) * 100;
  }
}

enum AlertSeverity { high, medium, low }

enum AlertConfidence { high, moderate, low }

class TerritorialAlert {
  final String id;
  final String category;
  final String title;
  final String explanation;
  final String evidence;
  final String limitations;
  final String recommendedAction;
  final String methodology;
  final AlertSeverity severity;
  final AlertConfidence confidence;
  final bool synthetic;

  const TerritorialAlert({
    required this.id,
    required this.category,
    required this.title,
    required this.explanation,
    required this.evidence,
    required this.limitations,
    required this.recommendedAction,
    required this.methodology,
    required this.severity,
    required this.confidence,
    required this.synthetic,
  });

  String get confidenceLabel => switch (confidence) {
        AlertConfidence.high => 'Alta (qualitativa)',
        AlertConfidence.moderate => 'Moderada (qualitativa)',
        AlertConfidence.low => 'Baixa (qualitativa)',
      };
  String get severityLabel => switch (severity) {
        AlertSeverity.high => 'Alta prioridade',
        AlertSeverity.medium => 'Atenção',
        AlertSeverity.low => 'Informativo',
      };
}
