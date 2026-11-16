import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:territorio_vivo/data/app_controller.dart';
import 'package:territorio_vivo/data/weather_api.dart';
import 'package:territorio_vivo/models/territory_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Primeira abertura sem cache disponibiliza demonstração rotulada', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState.fromPrefs(prefs);
    expect(state.consent, false);
    expect(state.weather.origin, DataOrigin.synthetic);
    expect(state.reports, isEmpty);
  });

  test('Configuração de limiares é compartilhada e persistida', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final api = WeatherApi();
    final controller = AppController(prefs, api);
    await controller.saveThresholds(rain: 35, heat: 37);
    expect(controller.snapshot.rainThresholdMm, 35);
    expect(controller.snapshot.heatThresholdC, 37);
    expect(prefs.getDouble('rain_mm'), 35);
    controller.dispose();
    api.close();
  });

  test('Registro de ocorrência não exige nome nem endereço', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final api = WeatherApi();
    final controller = AppController(prefs, api);
    await controller.addReport(region: 'Centro', category: 'Iluminação', description: 'Poste sem iluminação na região');
    final restored = AppState.fromPrefs(prefs);
    expect(restored.reports.length, 1);
    expect(restored.reports.first.region, 'Centro');
    await controller.deleteReports();
    expect(AppState.fromPrefs(prefs).reports, isEmpty);
    controller.dispose();
    api.close();
  });
}
