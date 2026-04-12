import 'package:flutter/material.dart';

import '../data/database_holder.dart';
import '../data/entities/pet.dart';
import '../widgets/reactive_layout.dart';

/// **Pets** module — list + SQLite + responsive detail (same pattern as [PetOwnerScreen]).
class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  List<Pet> _rows = [];
  Pet? _selected;

  final _name = TextEditingController();
  final _birthday = TextEditingController();
  final _species = TextEditingController();
  final _colour = TextEditingController();
  final _ownerId = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _name.dispose();
    _birthday.dispose();
    _species.dispose();
    _colour.dispose();
    _ownerId.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final list = await DatabaseHolder.instance.petDao.findAll();
    if (!mounted) return;
    setState(() => _rows = list);
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    final bday = _birthday.text.trim();
    final species = _species.text.trim();
    final colour = _colour.text.trim();
    final oid = int.tryParse(_ownerId.text.trim());

    if (name.isEmpty || bday.isEmpty || species.isEmpty || colour.isEmpty || oid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields including numeric owner ID are required.')),
      );
      return;
    }

    await DatabaseHolder.instance.petDao.insertPet(
      Pet(name: name, birthday: bday, species: species, colour: colour, ownerId: oid),
    );
    _name.clear();
    _birthday.clear();
    _species.clear();
    _colour.clear();
    _ownerId.clear();
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet saved.')));
  }

  void _help() {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('How to use — Pets'),
        content: const Text('Fill all fields, add the pet, tap a row for details. Wide layout shows list and details together.'),
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
              TextField(controller: _species, decoration: const InputDecoration(labelText: 'Species', border: OutlineInputBorder())),
              const SizedBox(height: 6),
              TextField(controller: _colour, decoration: const InputDecoration(labelText: 'Colour', border: OutlineInputBorder())),
              const SizedBox(height: 6),
              TextField(
                controller: _ownerId,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Owner ID', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              FilledButton(onPressed: _add, child: const Text('Add pet')),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _rows.isEmpty
              ? const Center(child: Text('No pets yet.'))
              : ListView.builder(
                  itemCount: _rows.length,
                  itemBuilder: (context, i) {
                    final p = _rows[i];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text('${p.species} · owner #${p.ownerId}'),
                      onTap: () => setState(() => _selected = p),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _detail() {
    final p = _selected;
    if (p == null) return const Center(child: Text('Select a pet.'));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: Theme.of(context).textTheme.titleLarge),
          Text('Name: ${p.name}'),
          Text('Birthday: ${p.birthday}'),
          Text('Species: ${p.species}'),
          Text('Colour: ${p.colour}'),
          Text('Owner ID: ${p.ownerId}'),
          const Spacer(),
          FilledButton.tonal(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete pet?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await DatabaseHolder.instance.petDao.deletePet(p);
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
        title: const Text('Pets'),
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
