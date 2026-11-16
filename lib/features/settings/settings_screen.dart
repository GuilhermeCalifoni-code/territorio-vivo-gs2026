import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/app_controller.dart';
import '../../widgets/common.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _rain;
  late final TextEditingController _heat;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appProvider);
    _rain = TextEditingController(text: state.rainThresholdMm.toStringAsFixed(0));
    _heat = TextEditingController(text: state.heatThresholdC.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _rain.dispose();
    _heat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(appProvider.notifier).saveThresholds(
        rain: double.parse(_rain.text.replaceAll(',', '.')),
        heat: double.parse(_heat.text.replaceAll(',', '.')),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Limiares salvos. Alertas recalculados em todas as telas.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível salvar os limiares. Tente novamente.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validateNumber(String? value, {required double min, required double max}) {
    final result = double.tryParse((value ?? '').replaceAll(',', '.'));
    if (result == null) return 'Informe um número válido.';
    if (!result.isFinite || result < min || result > max) return 'Use um valor de $min a $max.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    return PageContent(children: [
      const Headline('Preferências & privacidade', subtitle: 'Transparência, acessibilidade e controle de dados'),
      const SectionTitle('Limiares personalizados'),
      Form(key: _formKey, child: SurfacePanel(child: Column(children: [
        TextFormField(
          controller: _rain,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Chuva acumulada em 6h (mm)', prefixIcon: Icon(Icons.water_drop_outlined)),
          validator: (v) => _validateNumber(v, min: 1, max: 200),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _heat,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Temperatura máxima (°C)', prefixIcon: Icon(Icons.thermostat_outlined)),
          validator: (v) => _validateNumber(v, min: 20, max: 50),
        ),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: _saving ? null : _save, icon: const Icon(Icons.check), label: const Text('Salvar limites'),
        )),
      ]))),
      const SectionTitle('Acessibilidade'),
      SurfacePanel(child: Column(children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero, title: const Text('Modo escuro'),
          subtitle: const Text('Alternar aparência do aplicativo'),
          value: state.darkMode, onChanged: (v) => ref.read(appProvider.notifier).setDarkMode(v),
        ),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero, title: const Text('Alto contraste'),
          subtitle: const Text('Aumentar a distinção entre elementos'),
          value: state.highContrast, onChanged: (v) => ref.read(appProvider.notifier).setHighContrast(v),
        ),
        const Divider(),
        const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.accessibility_new), title: Text('Fonte do sistema e leitor de tela'), subtitle: Text('Textos seguem a escala de fontes do dispositivo; gráficos possuem resumo semântico.')),
      ])),
      const SectionTitle('Seus dados'),
      SurfacePanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ocorrências guardadas: ${state.reports.length}'),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: state.reports.isEmpty ? null : () async {
          final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
            title: const Text('Apagar ocorrências?'),
            content: const Text('Todos os relatos locais serão apagados deste dispositivo.'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Apagar'))],
          ));
          if (confirmed == true) await ref.read(appProvider.notifier).deleteReports();
        }, icon: const Icon(Icons.delete_outline), label: const Text('Apagar relatos locais')),
        const Divider(height: 25),
        OutlinedButton.icon(onPressed: () async {
          final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
            title: const Text('Revogar consentimento?'),
            content: const Text('Isso remove cache meteorológico e ocorrências locais e retorna à tela inicial de consentimento.'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Revogar'))],
          ));
          if (confirmed == true) await ref.read(appProvider.notifier).setConsent(false);
        }, icon: const Icon(Icons.no_accounts_outlined), label: const Text('Revogar consentimento e limpar dados')),
      ])),
      const SectionTitle('Fontes e limitações'),
      const NoteBox('Clima: Open-Meteo (previsão pública); recursos e serviços: séries 100% sintéticas; relatos: somente locais. Não coletamos identificadores pessoais, nem localização precisa, nem enviamos relatos a servidores.'),
      const NoteBox('Os alertas não são calibrados com histórico de desastres e não têm taxa de acerto validada. Qualquer decisão de alto impacto requer um profissional responsável. Projeto acadêmico FIAP · CitizenTech · Global Solution 2026.2.'),
    ]);
  }
}
