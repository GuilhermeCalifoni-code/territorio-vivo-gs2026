import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:territorio_vivo/data/app_controller.dart';
import 'package:territorio_vivo/data/weather_api.dart';
import 'package:territorio_vivo/features/consent/consent_screen.dart';
import 'package:territorio_vivo/main.dart';
import 'package:territorio_vivo/models/territory_models.dart';

class _OfflineWeatherApi extends WeatherApi {
  @override
  Future<WeatherSnapshot> fetch() async => WeatherSnapshot.demonstration(
        DateTime(2026, 11, 15, 12),
      );
}

/// A tela de consentimento é uma ListView longa: em telas pequenas o botão
/// fica fora da área visível e não é construído. Rola até cada elemento.
Future<void> _acceptConsent(WidgetTester tester) async {
  final list = find.byType(Scrollable).first;
  final checkbox = find.byType(CheckboxListTile);
  await tester.scrollUntilVisible(checkbox, 120, scrollable: list);
  await tester.ensureVisible(checkbox);
  await tester.pumpAndSettle();
  await tester.tap(checkbox);
  await tester.pump();
  final enter = find.text('Entrar no painel');
  await tester.scrollUntilVisible(enter, 120, scrollable: list);
  await tester.ensureVisible(enter);
  await tester.pumpAndSettle();
  await tester.tap(enter);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Aceitar, salvar limiares, revogar e aceitar consentimento novamente', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        weatherApiProvider.overrideWithValue(_OfflineWeatherApi()),
      ],
      child: const TerritorioVivoApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ConsentScreen), findsOneWidget);
    await _acceptConsent(tester);
    expect(prefs.getBool('consent_v1'), true);
    expect(find.text('São Paulo em perspectiva'), findsOneWidget);

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    expect(find.text('Preferências & privacidade'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '200');
    await tester.enterText(find.byType(TextFormField).at(1), '50');
    await tester.ensureVisible(find.text('Salvar limites'));
    await tester.tap(find.text('Salvar limites'));
    await tester.pumpAndSettle();
    expect(prefs.getDouble('rain_mm'), 200);
    expect(prefs.getDouble('heat_c'), 50);

    await tester.ensureVisible(find.text('Revogar consentimento e limpar dados'));
    await tester.tap(find.text('Revogar consentimento e limpar dados'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revogar'));
    await tester.pumpAndSettle();
    expect(find.byType(ConsentScreen), findsOneWidget);
    expect(prefs.getBool('consent_v1'), false);

    await _acceptConsent(tester);
    expect(find.text('São Paulo em perspectiva'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rotas dos painéis e formulários não quebram a navegação', (tester) async {
    SharedPreferences.setMockInitialValues({'consent_v1': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        weatherApiProvider.overrideWithValue(_OfflineWeatherApi()),
      ],
      child: const TerritorioVivoApp(),
    ));
    await tester.pumpAndSettle();

    for (final path in [
      '/overview', '/climate', '/resources', '/services', '/alerts',
      '/alerts/rain', '/indicators/climate/rain',
      '/indicators/resources/water', '/indicators/services/demand',
      '/report', '/settings',
    ]) {
      GoRouter.of(tester.element(find.byType(AppShell))).go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Erro na rota $path');
    }
  });
}
