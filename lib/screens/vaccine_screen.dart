import 'package:flutter/material.dart';

import '../data/database_holder.dart';
import '../data/entities/vaccine.dart';
import '../data/vaccine_previous_prefs.dart';

/// This is the main vaccines screen.
/// It shows the vaccine list and an add button.
class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  // This list holds vaccines loaded from the database.
  List<Vaccine> _rows = [];

  @override
  void initState() {
    super.initState();
    // Load data when screen opens.
    _reload();
  }

  Future<void> _reload() async {
    // Ask DAO for all vaccines.
    final list = await DatabaseHolder.instance.vaccineDao.findAll();
    if (!mounted) return;
    // Refresh UI with latest list.
    setState(() => _rows = list);
  }

  Future<void> _openAdd() async {
    // This will hold copied values if user chooses "Copy previous".
    Vaccine? prefill;

    // If we have saved previous values, ask user which mode they want.
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
      // User canceled the add flow.
      if (useCopy == null) return;
      // User wants copied values.
      if (useCopy) {
        prefill = await VaccinePreviousPrefs.loadTemplate();
      }
    }
    if (!mounted) return;

    // Open the same form page in add mode.
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => VaccineFormPage(prefill: prefill),
      ),
    );

    // If form saved/deleted something, reload list.
    if (changed == true && mounted) await _reload();
  }

  Future<void> _openEdit(Vaccine v) async {
    // Open the same form page in edit mode.
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => VaccineFormPage(existing: v),
      ),
    );

    // If form saved/deleted something, reload list.
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
      // Floating add button.
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        tooltip: 'Add vaccine',
        child: const Icon(Icons.add),
      ),
      // Show empty text when there is no data.
      // Otherwise show one list row per vaccine.
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

/// This page is used for both add and edit.
/// - existing: edit mode
/// - prefill: add mode with copied previous values
class VaccineFormPage extends StatefulWidget {
  const VaccineFormPage({super.key, this.existing, this.prefill})
      : assert(existing == null || prefill == null);

  final Vaccine? existing;
  final Vaccine? prefill;

  @override
  State<VaccineFormPage> createState() => _VaccineFormPageState();
}

class _VaccineFormPageState extends State<VaccineFormPage> {
  // Controllers store what user types in each text box.
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _lot = TextEditingController();
  final _exp = TextEditingController();

  // True means we are editing an existing vaccine.
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    // Pick source data for initial field values.
    // Existing vaccine for edit, or prefill for add.
    final Vaccine? seed = widget.existing ?? widget.prefill;
    if (seed != null) {
      // Put initial values in the text boxes.
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
    // Read all fields and trim spaces.
    final name = _name.text.trim();
    final dosage = _dosage.text.trim();
    final lot = _lot.text.trim();
    final exp = _exp.text.trim();

    // All fields are required.
    if (name.isEmpty || dosage.isEmpty || lot.isEmpty || exp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All vaccine fields are required.')),
      );
      return false;
    }
    return true;
  }

  Future<void> _submitAdd() async {
    // Stop if form is not valid.
    if (!_validateFields()) return;

    // Build Vaccine object from form text.
    final name = _name.text.trim();
    final dosage = _dosage.text.trim();
    final lot = _lot.text.trim();
    final exp = _exp.text.trim();
    final row = Vaccine(name: name, dosage: dosage, lotNumber: lot, expirationDate: exp);

    // Save new vaccine in database using DAO.
    await DatabaseHolder.instance.vaccineDao.insertVaccine(row);

    // Save same data as "previous vaccine" for copy option.
    await VaccinePreviousPrefs.saveLastCreated(row);
    if (!mounted) return;

    // Show message and return true so list screen reloads.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaccine saved.')));
    Navigator.of(context).pop(true);
  }

  Future<void> _submitUpdate() async {
    // Stop if form is not valid.
    if (!_validateFields()) return;

    // We need an id to update existing row.
    final id = widget.existing!.id;
    if (id == null) return;

    // Build updated object using same id.
    final name = _name.text.trim();
    final dosage = _dosage.text.trim();
    final lot = _lot.text.trim();
    final exp = _exp.text.trim();

    // Save updated vaccine in database using DAO.
    await DatabaseHolder.instance.vaccineDao.updateVaccine(
      Vaccine(id: id, name: name, dosage: dosage, lotNumber: lot, expirationDate: exp),
    );
    if (!mounted) return;

    // Show message and return true so list screen reloads.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaccine updated.')));
    Navigator.of(context).pop(true);
  }

  Future<void> _confirmDelete() async {
    // Vaccine being edited right now.
    final v = widget.existing!;

    // Ask user before deleting.
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

    // Delete from database using DAO.
    await DatabaseHolder.instance.vaccineDao.deleteVaccine(v);
    if (!mounted) return;

    // Show message and return true so list screen reloads.
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
            // In edit mode we show Update and Delete.
            if (_isEdit) ...[
              FilledButton(onPressed: _submitUpdate, child: const Text('Update')),
              const SizedBox(height: 8),
              FilledButton.tonal(onPressed: _confirmDelete, child: const Text('Delete')),
            ] else
              // In add mode we only show Add button.
              FilledButton(onPressed: _submitAdd, child: const Text('Add vaccine')),
          ],
        ),
      ),
    );
  }
}
