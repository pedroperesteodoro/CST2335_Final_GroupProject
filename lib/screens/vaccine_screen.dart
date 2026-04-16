import 'package:flutter/material.dart';

import '../app_localizations.dart';
import '../data/database_holder.dart';
import '../data/entities/vaccine.dart';
import '../data/vaccine_previous_prefs.dart';
import '../main.dart';

class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  List<Vaccine> _rows = [];

  String _t(String key) => AppLocalizations.of(context)?.translate(key) ?? key;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final list = await DatabaseHolder.instance.vaccineDao.findAll();
    if (!mounted) return;
    setState(() => _rows = list);
  }

  Future<void> _openAdd() async {
    Vaccine? prefill;
    if (await VaccinePreviousPrefs.hasPrevious()) {
      if (!mounted) return;
      final useCopy = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(_t('vac_new_title')),
          content: Text(_t('vac_new_body')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_t('cancel'))),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_t('start_blank')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_t('copy_previous')),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (useCopy == null) return;
      if (useCopy) {
        prefill = await VaccinePreviousPrefs.loadTemplate();
      }
    }
    if (!mounted) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => VaccineFormPage(prefill: prefill),
      ),
    );
    if (changed == true && mounted) await _reload();
  }

  Future<void> _openEdit(Vaccine v) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => VaccineFormPage(existing: v),
      ),
    );
    if (changed == true && mounted) await _reload();
  }

  void _help() {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(_t('vac_help_title')),
        content: Text(_t('vac_help_body')),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(_t('ok')))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('vaccines')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final current = Localizations.localeOf(context);
              MyApp.setLocale(
                context,
                current.languageCode == 'en' ? const Locale('fr') : const Locale('en'),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.help_outline), onPressed: _help),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        tooltip: _t('vac_add'),
        child: const Icon(Icons.add),
      ),
      body: _rows.isEmpty
          ? Center(child: Text(_t('vac_none')))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: _rows.length,
              itemBuilder: (context, i) {
                final v = _rows[i];
                return ListTile(
                  title: Text(v.name),
                  subtitle: Text('${v.dosage} · ${_t('vac_lot_short')} ${v.lotNumber} · ${_t('vac_exp_short')} ${v.expirationDate}'),
                  onTap: () => _openEdit(v),
                );
              },
            ),
    );
  }
}

class VaccineFormPage extends StatefulWidget {
  const VaccineFormPage({super.key, this.existing, this.prefill})
      : assert(existing == null || prefill == null);

  final Vaccine? existing;
  final Vaccine? prefill;

  @override
  State<VaccineFormPage> createState() => _VaccineFormPageState();
}

class _VaccineFormPageState extends State<VaccineFormPage> {
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _lot = TextEditingController();
  final _exp = TextEditingController();

  bool get _isEdit => widget.existing != null;

  String _t(String key) => AppLocalizations.of(context)?.translate(key) ?? key;

  @override
  void initState() {
    super.initState();
    final Vaccine? seed = widget.existing ?? widget.prefill;
    if (seed != null) {
      _name.text = seed.name;
      _dosage.text = seed.dosage;
      _lot.text = seed.lotNumber;
      _exp.text = seed.expirationDate;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _lot.dispose();
    _exp.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final name = _name.text.trim();
    final dosage = _dosage.text.trim();
    final lot = _lot.text.trim();
    final exp = _exp.text.trim();
    if (name.isEmpty || dosage.isEmpty || lot.isEmpty || exp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('vac_required'))),
      );
      return false;
    }
    return true;
  }

  Future<void> _submitAdd() async {
    if (!_validateFields()) return;
    final name = _name.text.trim();
    final dosage = _dosage.text.trim();
    final lot = _lot.text.trim();
    final exp = _exp.text.trim();
    final row = Vaccine(name: name, dosage: dosage, lotNumber: lot, expirationDate: exp);
    await DatabaseHolder.instance.vaccineDao.insertVaccine(row);
    await VaccinePreviousPrefs.saveLastCreated(row);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('vac_saved'))));
    Navigator.of(context).pop(true);
  }

  Future<void> _submitUpdate() async {
    if (!_validateFields()) return;
    final id = widget.existing!.id;
    if (id == null) return;
    final name = _name.text.trim();
    final dosage = _dosage.text.trim();
    final lot = _lot.text.trim();
    final exp = _exp.text.trim();
    await DatabaseHolder.instance.vaccineDao.updateVaccine(
      Vaccine(id: id, name: name, dosage: dosage, lotNumber: lot, expirationDate: exp),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('vac_updated'))));
    Navigator.of(context).pop(true);
  }

  Future<void> _confirmDelete() async {
    final v = widget.existing!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('vac_delete_title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(_t('cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(_t('delete'))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await DatabaseHolder.instance.vaccineDao.deleteVaccine(v);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('vac_deleted'))));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? _t('vac_edit_title') : _t('vac_add_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: _t('full_name'), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dosage,
              decoration: InputDecoration(labelText: _t('vac_dosage'), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lot,
              decoration: InputDecoration(labelText: _t('vac_lot'), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _exp,
              decoration: InputDecoration(
                labelText: _t('vac_exp'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_isEdit) ...[
              FilledButton(onPressed: _submitUpdate, child: Text(_t('update'))),
              const SizedBox(height: 8),
              FilledButton.tonal(onPressed: _confirmDelete, child: Text(_t('delete'))),
            ] else
              FilledButton(onPressed: _submitAdd, child: Text(_t('vac_add'))),
          ],
        ),
      ),
    );
  }
}
