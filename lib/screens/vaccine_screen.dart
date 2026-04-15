import 'package:flutter/material.dart';

import '../data/database_holder.dart';
import '../data/entities/vaccine.dart';
import '../data/vaccine_previous_prefs.dart';

/// **Vaccines** module — list + SQLite + add/edit form page.
class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  List<Vaccine> _rows = [];

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
          title: const Text('New vaccine'),
          content: const Text(
            'Copy fields from your previous vaccine entry, or start with a blank form?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Start blank'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Copy previous'),
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
        title: const Text('How to use — Vaccines'),
        content: const Text(
          'Use Add to create a vaccine, or tap a row to edit or delete. '
          'List order follows expiration in the database query.',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccines'),
        actions: [IconButton(icon: const Icon(Icons.help_outline), onPressed: _help)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        tooltip: 'Add vaccine',
        child: const Icon(Icons.add),
      ),
      body: _rows.isEmpty
          ? const Center(child: Text('No vaccines yet.'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: _rows.length,
              itemBuilder: (context, i) {
                final v = _rows[i];
                return ListTile(
                  title: Text(v.name),
                  subtitle: Text('${v.dosage} · Lot ${v.lotNumber} · exp ${v.expirationDate}'),
                  onTap: () => _openEdit(v),
                );
              },
            ),
    );
  }
}

/// Create or edit a [Vaccine]. Pass [existing] for edit mode, or [prefill] when adding with copied fields.
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
        const SnackBar(content: Text('All vaccine fields are required.')),
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaccine saved.')));
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaccine updated.')));
    Navigator.of(context).pop(true);
  }

  Future<void> _confirmDelete() async {
    final v = widget.existing!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete vaccine?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await DatabaseHolder.instance.vaccineDao.deleteVaccine(v);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaccine deleted.')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit vaccine' : 'Add vaccine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dosage,
              decoration: const InputDecoration(labelText: 'Dosage', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lot,
              decoration: const InputDecoration(labelText: 'Lot #', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _exp,
              decoration: const InputDecoration(
                labelText: 'Expiration (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_isEdit) ...[
              FilledButton(onPressed: _submitUpdate, child: const Text('Update')),
              const SizedBox(height: 8),
              FilledButton.tonal(onPressed: _confirmDelete, child: const Text('Delete')),
            ] else
              FilledButton(onPressed: _submitAdd, child: const Text('Add vaccine')),
          ],
        ),
      ),
    );
  }
}
