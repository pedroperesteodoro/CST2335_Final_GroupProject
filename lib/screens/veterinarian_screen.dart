import 'package:flutter/material.dart';

import '../data/database_holder.dart';
import '../data/entities/veterinarian.dart';
import '../widgets/reactive_layout.dart';

/// **Veterinarians** module — staff records in SQLite.
class VeterinarianScreen extends StatefulWidget {
  const VeterinarianScreen({super.key});

  @override
  State<VeterinarianScreen> createState() => _VeterinarianScreenState();
}

class _VeterinarianScreenState extends State<VeterinarianScreen> {
  List<Veterinarian> _rows = [];
  Veterinarian? _selected;

  final _name = TextEditingController();
  final _birthday = TextEditingController();
  final _address = TextEditingController();
  final _university = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _name.dispose();
    _birthday.dispose();
    _address.dispose();
    _university.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final list = await DatabaseHolder.instance.veterinarianDao.findAll();
    if (!mounted) return;
    setState(() => _rows = list);
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    final bday = _birthday.text.trim();
    final addr = _address.text.trim();
    final uni = _university.text.trim();
    if (name.isEmpty || bday.isEmpty || addr.isEmpty || uni.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All veterinarian fields are required.')),
      );
      return;
    }
    await DatabaseHolder.instance.veterinarianDao.insertVeterinarian(
      Veterinarian(name: name, birthday: bday, address: addr, university: uni),
    );
    _name.clear();
    _birthday.clear();
    _address.clear();
    _university.clear();
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veterinarian saved.')));
  }

  void _help() {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('How to use — Veterinarians'),
        content: const Text('Add staff with full profile fields; tap a row to inspect or delete.'),
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
              TextField(controller: _birthday, decoration: const InputDecoration(labelText: 'Birthday', border: OutlineInputBorder())),
              const SizedBox(height: 6),
              TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
              const SizedBox(height: 6),
              TextField(controller: _university, decoration: const InputDecoration(labelText: 'University', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              FilledButton(onPressed: _add, child: const Text('Add veterinarian')),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _rows.isEmpty
              ? const Center(child: Text('No veterinarians yet.'))
              : ListView.builder(
                  itemCount: _rows.length,
                  itemBuilder: (context, i) {
                    final v = _rows[i];
                    return ListTile(
                      title: Text(v.name),
                      subtitle: Text(v.university),
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
    if (v == null) return const Center(child: Text('Select a veterinarian.'));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: Theme.of(context).textTheme.titleLarge),
          Text('Name: ${v.name}'),
          Text('Birthday: ${v.birthday}'),
          Text('Address: ${v.address}'),
          Text('University: ${v.university}'),
          const Spacer(),
          FilledButton.tonal(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete veterinarian?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await DatabaseHolder.instance.veterinarianDao.deleteVeterinarian(v);
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
        title: const Text('Veterinarians'),
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
