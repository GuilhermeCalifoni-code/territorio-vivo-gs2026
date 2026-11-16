import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:territorio_vivo/widgets/common.dart';
import 'package:territorio_vivo/models/territory_models.dart';

void main() {
  testWidgets('Card de indicador mostra informação relevante', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MetricCard(
      icon: Icons.water_drop,
      label: 'Índice de consumo',
      value: '155',
      detail: 'Série sintética',
    ))));
    expect(find.text('Índice de consumo'), findsOneWidget);
    expect(find.text('155'), findsOneWidget);
    expect(find.text('Série sintética'), findsOneWidget);
  });

  testWidgets('Série sintética fixa não informa data de coleta falsa', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: DataSourceBanner(origin: DataOrigin.synthetic),
    )));
    expect(find.textContaining('Série fixa de demonstração'), findsOneWidget);
    expect(find.textContaining('Atualização:'), findsNothing);
  });
}
