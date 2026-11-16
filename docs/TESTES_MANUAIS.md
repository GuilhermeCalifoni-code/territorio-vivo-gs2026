# Protocolo de validação manual

> Marque após testar em aparelho/emulador real. Não considerar testado apenas porque o código existe.

- [ ] Primeira abertura mostra consentimento; botão bloqueado até aceitar.
- [ ] Home abre, cards coerentes e nenhum overflow.
- [ ] `Clima` atualiza via API com internet; origem **DADOS REAIS**.
- [ ] Desligar internet e atualizar: mostra mensagem clara e cache rotulado.
- [ ] Limpar cache/consentimento, abrir sem internet: origem **DEMONSTRAÇÃO**.
- [ ] Gráficos de clima apresentam valores e toque com detalhes.
- [ ] Recursos e Serviços sempre identificados como dados sintéticos.
- [ ] Alertas exibem evidência, confiança, limitações e supervisão humana.
- [ ] Alterar limites: alerta de chuva/calor recalculado em outra tela.
- [ ] Formulário vazio exibe validações, impede envio.
- [ ] Formulário correto salva localmente e retorna ao painel.
- [ ] Fechar e reabrir app mantém relatos e preferências.
- [ ] Estado vazio de relatos sem registros é amigável.
- [ ] Excluir relatos realmente remove registros.
- [ ] Revogar consentimento remove cache/relatos e volta à tela inicial.
- [ ] Modo claro, escuro e alto contraste legíveis.
- [ ] Fontes ampliadas 150% e TalkBack funcionando.
- [ ] Testado em 360×800 e 412×915 (ou outros dois tamanhos comprovados).
- [ ] `flutter analyze` sem erros.
- [ ] `flutter test` sem erros.
- [ ] `flutter build apk --release` concluído e APK instalável.
- [ ] 10 capturas reais inseridas em `assets/screenshots/`.
- [ ] README atualizado com galeria e URL do vídeo.
- [ ] Vídeo em acesso público com <= 3 minutos.
- [ ] Repositório GitHub público e links abrem sem login.
- [ ] TXT final gerado e link conferido.
