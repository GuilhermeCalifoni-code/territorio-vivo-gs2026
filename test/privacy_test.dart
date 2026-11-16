import 'package:flutter_test/flutter_test.dart';
import 'package:territorio_vivo/core/privacy.dart';

void main() {
  test('Oculta e-mail e CPF antes de salvar', () {
    const source = 'Exemplo teste@dominio.com com CPF 123.456.789-01';
    final sanitized = PrivacySanitizer.redact(source);
    expect(sanitized, contains('[e-mail removido]'));
    expect(sanitized, contains('[CPF removido]'));
    expect(sanitized, isNot(contains('teste@dominio.com')));
    expect(sanitized, isNot(contains('123.456.789-01')));
  });
}
