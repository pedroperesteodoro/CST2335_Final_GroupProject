import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import '../app_localizations.dart';
import '../data/database_holder.dart';
import '../data/entities/pet.dart';
import '../main.dart';
import '../widgets/reactive_layout.dart';

/// **Pets** module — list + SQLite + responsive detail (same pattern as [PetOwnerScreen]).
class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  String _t(String key) => AppLocalizations.of(context)?.translate(key) ?? key;
  /// Secure key-value store for "previous pet" and draft text.
  final EncryptedSharedPreferences _securePrefs = EncryptedSharedPreferences();

  List<Pet> _rows = [];
  Pet? _selected;
  int? _editingId;

  final _name = TextEditingController();
  final _birthday = TextEditingController();
  final _species = TextEditingController();
  final _colour = TextEditingController();
  final _ownerId = TextEditingController();

  static const _kPrevName = 'pet_prev_name';
  static const _kPrevBirthday = 'pet_prev_birthday';
  static const _kPrevSpecies = 'pet_prev_species';
  static const _kPrevColour = 'pet_prev_colour';
  static const _kPrevOwnerId = 'pet_prev_owner_id';
  static const _kDraftName = 'pet_draft_name';

  @override
  void initState() {
    super.initState();
    _reload();
    _loadSavedDraft();
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

  /// Assignment requirement: keep at least one typed value for next launch.
  Future<void> _saveDraftName() async {
    await _securePrefs.setString(_kDraftName, _name.text.trim());
  }

  /// Restores draft value from secure prefs so user sees continuity after restart.
  Future<void> _loadSavedDraft() async {
    final draftName = await _securePrefs.getString(_kDraftName);
    if (!mounted) return;
    if (draftName.isNotEmpty) {
      setState(() {
        _name.text = draftName;
      });
    }
  }

  /// Saves full last pet values; used for "Copy previous pet or blank".
  Future<void> _savePreviousPetSnapshot({
    required String name,
    required String birthday,
    required String species,
    required String colour,
    required String ownerId,
  }) async {
    await _securePrefs.setString(_kPrevName, name);
    await _securePrefs.setString(_kPrevBirthday, birthday);
    await _securePrefs.setString(_kPrevSpecies, species);
    await _securePrefs.setString(_kPrevColour, colour);
    await _securePrefs.setString(_kPrevOwnerId, ownerId);
  }

  /// Minimal required-field validation for this base implementation.
  String? _validateInputs() {
    final name = _name.text.trim();
    final bday = _birthday.text.trim();
    final species = _species.text.trim();
    final colour = _colour.text.trim();
    final oid = int.tryParse(_ownerId.text.trim());

    if (name.isEmpty || bday.isEmpty || species.isEmpty || colour.isEmpty || oid == null) {
      return 'All fields including numeric owner ID are required.';
    }
    return null;
  }

  /// Create action for the Pet form.
  Future<void> _add() async {
    final validationMessage = _validateInputs();
    if (validationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    final name = _name.text.trim();
    final bday = _birthday.text.trim();
    final species = _species.text.trim();
    final colour = _colour.text.trim();
    final ownerIdText = _ownerId.text.trim();
    final oid = int.parse(ownerIdText);

    await DatabaseHolder.instance.petDao.insertPet(
      Pet(name: name, birthday: bday, species: species, colour: colour, ownerId: oid),
    );
    await _savePreviousPetSnapshot(
      name: name,
      birthday: bday,
      species: species,
      colour: colour,
      ownerId: ownerIdText,
    );
    await _saveDraftName();
    _name.clear();
    _birthday.clear();
    _species.clear();
    _colour.clear();
    _ownerId.clear();
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet saved.')));
  }

  /// Update action when user selected a row and is editing same form fields.
  Future<void> _update() async {
    if (_editingId == null) return;
    final validationMessage = _validateInputs();
    if (validationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    final updated = Pet(
      id: _editingId,
      name: _name.text.trim(),
      birthday: _birthday.text.trim(),
      species: _species.text.trim(),
      colour: _colour.text.trim(),
      ownerId: int.parse(_ownerId.text.trim()),
    );

    await DatabaseHolder.instance.petDao.updatePet(updated);
    await _savePreviousPetSnapshot(
      name: updated.name,
      birthday: updated.birthday,
      species: updated.species,
      colour: updated.colour,
      ownerId: updated.ownerId.toString(),
    );
    await _saveDraftName();
    await _reload();
    if (!mounted) return;
    setState(() {
      _selected = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet updated.')));
  }

  /// Reset form to "add mode".
  void _resetFormToAddMode({bool clearFields = true}) {
    setState(() {
      _editingId = null;
      _selected = null;
      if (clearFields) {
        _name.clear();
        _birthday.clear();
        _species.clear();
        _colour.clear();
        _ownerId.clear();
      }
    });
  }

  /// Load selected list row into form fields so the same page can update/delete.
  void _loadPetIntoForm(Pet pet) {
    setState(() {
      _selected = pet;
      _editingId = pet.id;
      _name.text = pet.name;
      _birthday.text = pet.birthday;
      _species.text = pet.species;
      _colour.text = pet.colour;
      _ownerId.text = pet.ownerId.toString();
    });
  }

  /// Requirement: when starting a new pet, choose "copy previous" or "blank".
  Future<void> _promptNewPetChoice() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New pet entry'),
        content: const Text('Start with a blank form or copy fields from the previous pet?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'blank'), child: const Text('Blank')),
          FilledButton(onPressed: () => Navigator.pop(ctx, 'copy'), child: const Text('Copy previous')),
        ],
      ),
    );

    if (!mounted || choice == null) return;
    if (choice == 'blank') {
      _resetFormToAddMode(clearFields: true);
      return;
    }

    final prevName = await _securePrefs.getString(_kPrevName);
    final prevBirthday = await _securePrefs.getString(_kPrevBirthday);
    final prevSpecies = await _securePrefs.getString(_kPrevSpecies);
    final prevColour = await _securePrefs.getString(_kPrevColour);
    final prevOwnerId = await _securePrefs.getString(_kPrevOwnerId);

    setState(() {
      _editingId = null;
      _selected = null;
      _name.text = prevName;
      _birthday.text = prevBirthday;
      _species.text = prevSpecies;
      _colour.text = prevColour;
      _ownerId.text = prevOwnerId;
    });

    if (prevName.isEmpty && prevBirthday.isEmpty && prevSpecies.isEmpty && prevColour.isEmpty && prevOwnerId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous pet found yet. Start typing a new one.')),
      );
    }
  }

  Future<void> _deleteFromForm() async {
    final selected = _selected;
    if (selected == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete pet?'),
        content: const Text('This removes the pet from SQLite and the list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;
    await DatabaseHolder.instance.petDao.deletePet(selected);
    _resetFormToAddMode(clearFields: true);
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet removed.')));
  }

  void _help() {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('How to use — Pets'),
        content: const Text(
          'Use New pet to choose blank or copy previous values. '
              'Add creates a row, selecting a list row loads the same form for update/delete.',
        ),
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
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _editingId == null ? _add : _update,
                      child: Text(_editingId == null ? 'Add pet' : 'Update pet'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _promptNewPetChoice,
                      child: const Text('New pet'),
                    ),
                  ),
                ],
              ),
              if (_editingId != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: _deleteFromForm,
                        child: const Text('Delete pet'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _resetFormToAddMode(clearFields: true),
                        child: const Text('Cancel edit'),
                      ),
                    ),
                  ],
                ),
              ],
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
                onTap: () => _loadPetIntoForm(p),
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
            onPressed: _deleteFromForm,
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
        title: Text(_t('pets')),
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
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            onPressed: _promptNewPetChoice,
            tooltip: _t('pet_new'),
          ),
          IconButton(icon: const Icon(Icons.help_outline), onPressed: _help),
        ],
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
