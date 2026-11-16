import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/alert_engine.dart';
import '../core/privacy.dart';
import '../models/territory_models.dart';
import 'weather_api.dart';

final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('SharedPreferences não inicializado'));
final weatherApiProvider = Provider<WeatherApi>((ref) {
  final api = WeatherApi();
  ref.onDispose(api.close);
  return api;
});

final appProvider = StateNotifierProvider<AppController, AppState>((ref) => AppController(
      ref.watch(prefsProvider), ref.watch(weatherApiProvider),
    ));

class AppState {
  final bool consent;
  final bool isLoading;
  final String? errorMessage;
  final WeatherSnapshot weather;
  final List<IncidentReport> reports;
  final double rainThresholdMm;
  final double heatThresholdC;
  final bool darkMode;
  final bool highContrast;

  const AppState({
    required this.consent, required this.isLoading, required this.errorMessage,
    required this.weather, required this.reports, required this.rainThresholdMm,
    required this.heatThresholdC, required this.darkMode, required this.highContrast,
  });

  factory AppState.fromPrefs(SharedPreferences prefs) {
    WeatherSnapshot weather = WeatherSnapshot.demonstration();
    final cachedWeather = prefs.getString('weather_cache_v1');
    if (cachedWeather != null) {
      try {
        weather = WeatherSnapshot.fromJson(Map<String, dynamic>.from(jsonDecode(cachedWeather) as Map))
            .withOrigin(DataOrigin.cache);
      } catch (_) {
        weather = WeatherSnapshot.demonstration();
      }
    }
    List<IncidentReport> reports = [];
    try {
      reports = (jsonDecode(prefs.getString('reports_v1') ?? '[]') as List)
          .map((e) => IncidentReport.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) { /* Falha de cache isolada dos demais dados. */ }
    return AppState(
      consent: prefs.getBool('consent_v1') ?? false,
      isLoading: false, errorMessage: null, weather: weather,
      reports: reports, rainThresholdMm: prefs.getDouble('rain_mm') ?? 18,
      heatThresholdC: prefs.getDouble('heat_c') ?? 33,
      darkMode: prefs.getBool('dark_mode') ?? true,
      highContrast: prefs.getBool('high_contrast') ?? false,
    );
  }

  List<TerritorialAlert> get alerts => AlertEngine.evaluate(
        weather: weather, rainThresholdMm: rainThresholdMm,
        heatThresholdC: heatThresholdC,
      );

  AppState copyWith({
    bool? consent, bool? isLoading, String? errorMessage, bool clearError = false,
    WeatherSnapshot? weather, List<IncidentReport>? reports,
    double? rainThresholdMm, double? heatThresholdC,
    bool? darkMode, bool? highContrast,
  }) => AppState(
    consent: consent ?? this.consent,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    weather: weather ?? this.weather,
    reports: reports ?? this.reports,
    rainThresholdMm: rainThresholdMm ?? this.rainThresholdMm,
    heatThresholdC: heatThresholdC ?? this.heatThresholdC,
    darkMode: darkMode ?? this.darkMode,
    highContrast: highContrast ?? this.highContrast,
  );
}

class AppController extends StateNotifier<AppState> {
  AppController(this._prefs, this._api) : super(AppState.fromPrefs(_prefs)) {
    if (state.consent) unawaited(refreshWeather());
  }
  final SharedPreferences _prefs;
  final WeatherApi _api;

  AppState get snapshot => state;

  Future<void> setConsent(bool value) async {
    await _prefs.setBool('consent_v1', value);
    state = state.copyWith(consent: value);
    if (value) {
      await refreshWeather();
    } else {
      // Revogar consentimento remove ocorrências e cache.
      await _prefs.remove('weather_cache_v1');
      await _prefs.remove('reports_v1');
      state = state.copyWith(weather: WeatherSnapshot.demonstration(), reports: [], isLoading: false, clearError: true);
    }
  }

  Future<void> refreshWeather() async {
    if (!state.consent || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final snapshot = await _api.fetch();
      if (!mounted || !state.consent) return;
      await _prefs.setString('weather_cache_v1', jsonEncode(snapshot.toJson()));
      if (!mounted || !state.consent) return;
      state = state.copyWith(isLoading: false, weather: snapshot, clearError: true);
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível atualizar o clima. Exibindo ${state.weather.origin == DataOrigin.synthetic ? 'dados demonstrativos' : 'o último cache disponível'}.',
      );
    }
  }

  Future<void> saveThresholds({required double rain, required double heat}) async {
    await _prefs.setDouble('rain_mm', rain);
    await _prefs.setDouble('heat_c', heat);
    state = state.copyWith(rainThresholdMm: rain, heatThresholdC: heat);
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('dark_mode', value);
    state = state.copyWith(darkMode: value);
  }

  Future<void> setHighContrast(bool value) async {
    await _prefs.setBool('high_contrast', value);
    state = state.copyWith(highContrast: value);
  }

  Future<void> addReport({required String region, required String category, required String description}) async {
    final report = IncidentReport(
      id: DateTime.now().microsecondsSinceEpoch.toString(), createdAt: DateTime.now(),
      region: region, category: category, description: PrivacySanitizer.redact(description),
    );
    final list = [report, ...state.reports];
    await _prefs.setString('reports_v1', jsonEncode(list.map((e) => e.toJson()).toList()));
    state = state.copyWith(reports: list);
  }

  Future<void> deleteReports() async {
    await _prefs.remove('reports_v1');
    state = state.copyWith(reports: []);
  }
}
