#!/usr/bin/env python3
"""Cria TXT no formato exato do PDF após o usuário publicar GitHub e vídeo."""
import argparse
from pathlib import Path
from urllib.parse import urlparse

parser = argparse.ArgumentParser()
parser.add_argument('--github', required=True, help='https://github.com/usuario/repo')
parser.add_argument('--video', required=True, help='URL pública de vídeo do aplicativo (YouTube/Drive etc.)')
args = parser.parse_args()

def ensure_url(value: str, host: str | None = None):
    parsed = urlparse(value)
    if parsed.scheme != 'https' or not parsed.netloc:
        parser.error('URLs devem ser https válidas (sem placeholders).')
    if host and parsed.hostname not in ('github.com', 'www.github.com'):
        parser.error('O repositório deve estar no GitHub.')
    if any(part in value.lower() for part in ['placeholder', 'preencher', 'example.com']):
        parser.error('Endereço de exemplo não é permitido.')
    return value.strip()

repo = ensure_url(args.github, host='github')
video = ensure_url(args.video)
if len(urlparse(repo).path.strip('/').split('/')) < 2:
    parser.error('GitHub precisa ser URL de um repositório (usuário/nome).')

root = Path(__file__).resolve().parent.parent
content = f'''=== GLOBAL SOLUTION 2026.2 ===
Disciplina: Cross-Platform Application Development
Desafio: Territory Predictive Insights

Integrante 1: Bento Donato Garcia | RM: 561621
Integrante 2: Enzo Ribeiro Domingues Piazentin | RM: 564216
Integrante 3: Guilherme Domingues Califoni | RM: 565157

GitHub: {repo}
Vídeo: {video}
'''
(root / 'ENTREGA_FIAP_FINAL.txt').write_text(content, encoding='utf-8')
readme = root / 'README.md'
text = readme.read_text(encoding='utf-8')
text = text.replace('**Link público: PENDENTE DE GRAVAÇÃO**', f'**Link público: {video}**')
readme.write_text(text, encoding='utf-8')
print('Criado ENTREGA_FIAP_FINAL.txt. Verifique PUBLICAMENTE o acesso a ambos os links!')
