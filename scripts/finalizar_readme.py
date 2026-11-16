#!/usr/bin/env python3
"""Insere capturas REAIS na seção visual do README quando todas existem."""
from pathlib import Path

root = Path(__file__).resolve().parent.parent
readme = root / 'README.md'
folder = root / 'assets' / 'screenshots'
shots = [
    ('Consentimento', '01-consentimento.png'),
    ('Início', '02-inicio.png'),
    ('Clima', '03-clima.png'),
    ('Recursos', '04-recursos.png'),
    ('Serviços', '05-servicos.png'),
    ('Alertas', '06-alertas.png'),
    ('Detalhe do alerta', '07-detalhe-alerta.png'),
    ('Detalhe do indicador', '08-detalhe-indicador.png'),
    ('Formulário', '09-formulario.png'),
    ('Configurações', '10-configuracoes.png'),
]
missing = [name for _, name in shots if not (folder / name).is_file() or (folder / name).stat().st_size < 10_000]
if missing:
    raise SystemExit('FALTAM prints reais (ou arquivos estão pequenos): ' + ', '.join(missing))

rows = ['| Tela 1 | Tela 2 |', '|---|---|']
for i in range(0, len(shots), 2):
    pairs = shots[i:i + 2]
    cells = []
    for label, name in pairs:
        cells.append(f'<img src="assets/screenshots/{name}" width="280" alt="Captura real da tela {label}" />')
    rows.append('| ' + ' | '.join(cells) + ' |')
    rows.append('| ' + ' | '.join(f'**{label}**' for label, _ in pairs) + ' |')
text = readme.read_text(encoding='utf-8')
start = '<!-- SCREENSHOT_GALLERY_START -->'
end = '<!-- SCREENSHOT_GALLERY_END -->'
assert start in text and end in text
before = text.split(start)[0]
after = text.split(end, maxsplit=1)[1]
readme.write_text(before + start + '\n' + '\n'.join(rows) + '\n' + end + after, encoding='utf-8')
print('Galeria atualizada usando somente arquivos fornecidos de screenshots.')
