#!/usr/bin/env python3
"""Valida a estrutura local de acordo com as exigências do enunciado."""
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parent.parent
checks = {
  'pubspec.yaml': root / 'pubspec.yaml',
  'entry Flutter': root / 'lib/main.dart',
  'motor de alertas': root / 'lib/core/alert_engine.dart',
  'API externa': root / 'lib/data/weather_api.dart',
  'estado': root / 'lib/data/app_controller.dart',
  'dashboard': root / 'lib/features/dashboards/dashboard_screens.dart',
  'formulário': root / 'lib/features/report/report_screen.dart',
  'README': root / 'README.md',
  'teste motor': root / 'test/alert_engine_test.dart',
  'teste API': root / 'test/weather_api_test.dart',
}
for label, path in checks.items():
    ok = path.is_file() and path.stat().st_size > 100
    print(('OK ' if ok else 'FALTA ') + label)

names = ['01-consentimento', '02-inicio', '03-clima', '04-recursos', '05-servicos', '06-alertas',
         '07-detalhe-alerta', '08-detalhe-indicador', '09-formulario', '10-configuracoes']
missing = [name for name in names if not (root / 'assets/screenshots' / (name + '.png')).is_file()]
print('CAPTURAS: ' + ('OK' if not missing else 'PENDENTES: ' + ', '.join(missing)))
print('GRADLE WRAPPER: ' + ('OK' if (root / 'android/gradle/wrapper/gradle-wrapper.jar').is_file() else 'PENDENTE: rode preparar_android'))
final = root / 'ENTREGA_FIAP_FINAL.txt'
if final.is_file():
    content = final.read_text(encoding='utf-8')
    print('TXT FINAL: ' + ('OK' if content.count('https://') >= 2 else 'REVISAR LINKS'))
else:
    print('TXT FINAL: PENDENTE (publicar GitHub/vídeo)')

readme = (root / 'README.md').read_text(encoding='utf-8')
print('GALERIA README: ' + ('OK' if '<img src="assets/screenshots/' in readme else 'PENDENTE'))
print('NOTA: Este verificador NÃO compila Flutter e NÃO verifica a acessibilidade dos links pela internet.')
if any(not p.is_file() for p in checks.values()):
    sys.exit(1)
