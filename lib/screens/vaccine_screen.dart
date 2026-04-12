import 'package:flutter/material.dart';

import '../data/database_holder.dart';
import '../data/entities/vaccine.dart';
import '../widgets/reactive_layout.dart';

/// **Vaccines** module — inventory-style rows in SQLite.
class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  List<Vaccine> _rows = [];
  Vaccine? _selected;

  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _lot = TextEditingController();
  final _exp = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _lot.dispose();
    _exp.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final list = await DatabaseHolder.instance.vaccineDao.findAll();
    if (!mounted) return;
    setState(() => _rows = list);
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    final dosage = _dosage.text.trim();
    final lot = _lot.text.trim();
    final exp = _exp.text.trim();
    if (name.isEmpty || dosage.isEmpty || lot.isEmpty || exp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All vaccine fields are required.')),
      );
      return;
    }
    await DatabaseHolder.instance.vaccineDao.insertVaccine(
      Vaccine(name: name, dosage: dosage, lotNumber: lot, expirationDate: exp),
    );
    _name.clear();
    _dosage.clear();
    _lot.clear();
    _exp.clear();
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaccine saved.')));
  }

  void _help() {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('How to use — Vaccines'),
        content: const Text('Record name, dosage, lot, and expiry. List sorts by expiration in the DAO query.'),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
      ),
    );
  }

  Widget _list() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
              const SizedBox(height: 6),
              TextField(controller: _dosage, decoration: const InputDecoration(labelText: 'Dosage', border: OutlineInputBorder())),
              const SizedBox(height: 6),
              TextField(controller: _lot, decoration: const InputDecoration(labelText: 'Lot #', border: OutlineInputBorder())),
              const SizedBox(height: 6),
              TextField(controller: _exp, decoration: const InputDecoration(labelText: 'Expiration (YYYY-MM-DD)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              FilledButton(onPressed: _add, child: const Text('Add vaccine')),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _rows.isEmpty
              ? const Center(child: Text('No vaccines yet.'))
              : ListView.builder(
                  itemCount: _rows.length,
                  itemBuilder: (context, i) {
                    final v = _rows[i];
                    return ListTile(
                      title: Text(v.name),
                      subtitle: Text('Lot ${v.lotNumber} · exp ${v.expirationDate}'),
                      onTap: () => setState(() => _selected = v),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _detail() {
    final v = _selected;
    if (v == null) return const Center(child: Text('Select a vaccine.'));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: Theme.of(context).textTheme.titleLarge),
          Text('Name: ${v.name}'),
          Text('Dosage: ${v.dosage}'),
          Text('Lot: ${v.lotNumber}'),
          Text('Expires: ${v.expirationDate}'),
          const Spacer(),
          FilledButton.tonal(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete vaccine?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await DatabaseHolder.instance.vaccineDao.deleteVaccine(v);
                        setState(() => _selected = null);
                        await _reload();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = shouldShowMasterDetailSideBySide(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccines'),
        actions: [IconButton(icon: const Icon(Icons.help_outline), onPressed: _help)],
      ),
      body: wide
          ? Row(
              children: [
                Expanded(flex: 5, child: _list()),
                const VerticalDivider(width: 1),
                Expanded(flex: 5, child: _detail()),
              ],
            )
          : _selected == null
              ? _list()
              : Column(
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _selected = null),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                    Expanded(child: _detail()),
                  ],
                ),
    );
  }
}
