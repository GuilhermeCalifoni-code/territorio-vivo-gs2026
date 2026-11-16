import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/app_controller.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});
  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool acknowledged = false;
  bool saving = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 550),
      child: ListView(padding: const EdgeInsets.all(25), children: [
        const SizedBox(height: 48),
        const Icon(Icons.hub_outlined, color: AppPalette.teal, size: 72),
        const SizedBox(height: 20),
        Text('Território Vivo', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Text('Inteligência territorial para uma São Paulo mais preparada.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 30),
        const ListTile(leading: Icon(Icons.cloud_outlined), title: Text('Clima com fonte pública'), subtitle: Text('Consulta à Open-Meteo. Se estiver offline, usamos o último cache ou um cenário demonstrativo identificado.')),
        const ListTile(leading: Icon(Icons.visibility_outlined), title: Text('Previsões transparentes'), subtitle: Text('Alertas heurísticos com justificativas e limitações. A decisão final pertence às pessoas.')),
        const ListTile(leading: Icon(Icons.shield_outlined), title: Text('Privacidade desde o início'), subtitle: Text('Sem login, GPS, nome ou endereço exato. Preferências e relatos ficam apenas no dispositivo.')),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: acknowledged, onChanged: (v) => setState(() => acknowledged = v ?? false),
          title: const Text('Concordo com o armazenamento local das preferências e, caso registre ocorrências, dos respectivos relatos anônimos.'),
          subtitle: const Text('Você pode revogar o consentimento nas Configurações e apagar os dados locais.'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: acknowledged && !saving ? () async {
            setState(() => saving = true);
            await ref.read(appProvider.notifier).setConsent(true);
            if (mounted) setState(() => saving = false);
          } : null,
          icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_forward),
          label: const Text('Entrar no painel'),
        ),
        const SizedBox(height: 15),
        Text('Projeto acadêmico FIAP · GS 2026.2', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
      ]),
    ))),
  );
}
