import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_controller.dart';
import '../../widgets/common.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});
  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  String? _region;
  String? _category;
  bool _agreed = false;
  bool _saving = false;

  static const regions = ['Centro', 'Zona Norte', 'Zona Sul', 'Zona Leste', 'Zona Oeste'];
  static const categories = ['Resíduos', 'Iluminação', 'Via pública', 'Água', 'Outros'];

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirme o consentimento para armazenar o relato localmente.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(appProvider.notifier).addReport(
        region: _region!, category: _category!, description: _description.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ocorrência salva no dispositivo. Nenhum dado foi enviado à prefeitura.')));
      context.go('/services');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível salvar. Tente novamente.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageContent(children: [
    const Headline('Registrar ocorrência', subtitle: 'Participação cidadã, sem identificação pessoal'),
    const NoteBox('Este é um formulário local acadêmico: seu relato não será transmitido a órgãos públicos. Não informe dados pessoais. Padrões de e-mail, CPF e telefone serão removidos automaticamente, mas nomes não são detectados.', icon: Icons.privacy_tip_outlined),
    Form(key: _formKey, child: SurfacePanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DropdownButtonFormField<String>(
        initialValue: _region,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Região da cidade', prefixIcon: Icon(Icons.location_city_outlined)),
        items: [for (final value in regions) DropdownMenuItem(value: value, child: Text(value))],
        onChanged: (v) => setState(() => _region = v),
        validator: (v) => v == null ? 'Selecione uma região.' : null,
      ),
      const SizedBox(height: 18),
      DropdownButtonFormField<String>(
        initialValue: _category,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Categoria', prefixIcon: Icon(Icons.category_outlined)),
        items: [for (final value in categories) DropdownMenuItem(value: value, child: Text(value))],
        onChanged: (v) => setState(() => _category = v),
        validator: (v) => v == null ? 'Selecione uma categoria.' : null,
      ),
      const SizedBox(height: 18),
      TextFormField(
        controller: _description, minLines: 3, maxLines: 5, maxLength: 260,
        decoration: const InputDecoration(labelText: 'Descrição da ocorrência', hintText: 'Ex.: há acúmulo de lixo em uma via da região...', alignLabelWithHint: true),
        validator: (value) {
          final text = (value ?? '').trim();
          if (text.isEmpty) return 'Descreva a ocorrência.';
          if (text.length < 12) return 'Escreva pelo menos 12 caracteres.';
          if (text.length > 260) return 'Limite de 260 caracteres.';
          return null;
        },
      ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: _agreed, onChanged: (v) => setState(() => _agreed = v ?? false),
        title: const Text('Autorizo o armazenamento anônimo deste relato somente neste dispositivo.'),
      ),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: _saving ? null : _submit,
        icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
        label: const Text('Salvar ocorrência localmente'),
      )),
    ]))),
  ]);
}
