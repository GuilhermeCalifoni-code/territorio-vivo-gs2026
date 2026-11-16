# Matriz de rastreabilidade — Rubrica FIAP

| Critério | Pontos | Evidências no repositório | Prova necessária antes da entrega |
|---|---:|---|---|
| Navegação e fluxo | 1,0 | `lib/main.dart`: `GoRoute(name: ...)`, parâmetros `/alerts/:id`, `/indicators/:category/:metric` | Vídeo navegando sem falhas |
| 3 dashboards | 1,5 | `lib/features/dashboards/dashboard_screens.dart`, `TrendChart`, gráficos de clima/água/serviços | Prints e vídeo |
| Alertas e transparência | 1,5 | `lib/core/alert_engine.dart`, `lib/features/alerts/alert_screens.dart` | Mostrar alerta, evidência, nível e limitação |
| Estado | 1,0 | `lib/data/app_controller.dart`: `StateNotifierProvider`, carregamento, erro, vazio | Reiniciar, alterar limite e confirmar persistência |
| API e persistência offline | 1,0 | `lib/data/weather_api.dart`, `SharedPreferences`, fallback `WeatherSnapshot.demonstration()` | Internet off/on demonstrados |
| Formulário | 1,0 | `lib/features/report/report_screen.dart` | Mostrar erros de validação e sucesso |
| Identidade e UX | 1,0 | `lib/core/theme.dart`, `lib/widgets/common.dart` | Responsividade 2 resoluções |
| Acessibilidade/privacidade/impacto | 0,5 | Consentimento, Semantics, temas, app sem PII exigida, proxy no Início | TalkBack/escala + exclusão de dados |
| Código e README | 1,0 | `lib/`, `README.md`, `test/`, `.gitignore` | **Capturas reais de TODAS as telas são obrigatórias** |
| Vídeo | 0,5 | `docs/ROTEIRO_VIDEO.md` | **Link público do vídeo real de até 3 min** |

## Bloqueadores de nota zero

- Falha crítica de execução.
- Repositório privado ou URL quebrada.
- Falta do vídeo real demonstrando o app.
- Mais de três integrantes.
- Decisão automática de alto impacto.
- Plágio ou entrega tardia.

**Deadline do PDF:** 19/11/2026 às **23h55**, no portal FIAP.
