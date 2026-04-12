import 'package:flutter/material.dart';

import '../data/database_holder.dart';
import '../data/entities/pet_owner.dart';
import '../widgets/reactive_layout.dart';

/// **Pet Owners** module — base scaffold: form + [ListView], SQLite via Floor, responsive details.
///
/// Teammate extends this with EncryptedSharedPreferences, full validation, ActionBar help, i18n, etc.
class PetOwnerScreen extends StatefulWidget {
  const PetOwnerScreen({super.key});

  @override
  State<PetOwnerScreen> createState() => _PetOwnerScreenState();
}

class _PetOwnerScreenState extends State<PetOwnerScreen> {
  /// Rows shown in the list (loaded from SQLite on open and after writes).
  List<PetOwner> _rows = [];

  /// When non-null on narrow screens, the UI shows the detail pane instead of the list.
  PetOwner? _selected;

  final _first = TextEditingController();
  final _last = TextEditingController();
  final _address = TextEditingController();
  final _dob = TextEditingController();
  final _insurance = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reloadFromDb();
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _address.dispose();
    _dob.dispose();
    _insurance.dispose();
    super.dispose();
  }

  /// SQLite.txt: load list when the screen starts (async → `setState` when data returns).
  Future<void> _reloadFromDb() async {
    final dao = DatabaseHolder.instance.petOwnerDao;
    final list = await dao.findAll();
    if (!mounted) return;
    setState(() => _rows = list);
  }

  /// Minimal validation: assignment requires all except insurance before submit.
  Future<void> _onAddPressed() async {
    final first = _first.text.trim();
    final last = _last.text.trim();
    final address = _address.text.trim();
    final dob = _dob.text.trim();
    final ins = _insurance.text.trim();

    if (first.isEmpty || last.isEmpty || address.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill first name, last name, address, and DOB.')),
      );
      return;
    }

    final row = PetOwner(
      firstName: first,
      lastName: last,
      address: address,
      dateOfBirth: dob,
      insuranceNumber: ins.isEmpty ? null : ins,
    );

    await DatabaseHolder.instance.petOwnerDao.insertPetOwner(row);
    _first.clear();
    _last.clear();
    _address.clear();
    _dob.clear();
    _insurance.clear();
    await _reloadFromDb();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pet owner saved to the database.')),
    );
  }

  /// Shows the course-required help text in a modal dialog (ActionBar item below).
  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('How to use — Pet Owners'),
        content: const Text(
          'Enter customer fields, tap Add customer, then tap a row to see details. '
          'On a wide screen, details appear beside the list.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _buildListPane() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: _first,
                decoration: const InputDecoration(labelText: 'First name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _last,
                decoration: const InputDecoration(labelText: 'Last name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dob,
                decoration: const InputDecoration(labelText: 'Date of birth (YYYY-MM-DD)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _insurance,
                decoration: const InputDecoration(labelText: 'Insurance # (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              FilledButton(onPressed: _onAddPressed, child: const Text('Add customer')),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _rows.isEmpty
              ? const Center(child: Text('No customers yet.'))
              : ListView.builder(
                  itemCount: _rows.length,
                  itemBuilder: (context, i) {
                    final r = _rows[i];
                    return ListTile(
                      title: Text('${r.lastName}, ${r.firstName}'),
                      subtitle: Text(r.address),
                      onTap: () => setState(() => _selected = r),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDetailPane() {
    final r = _selected;
    if (r == null) {
      return const Center(child: Text('Select a customer from the list.'));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Name: ${r.firstName} ${r.lastName}'),
          Text('Address: ${r.address}'),
          Text('DOB: ${r.dateOfBirth}'),
          Text('Insurance: ${r.insuranceNumber ?? '—'}'),
          const Spacer(),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete customer?'),
                      content: const Text('This removes the row from SQLite.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await DatabaseHolder.instance.petOwnerDao.deletePetOwner(r);
                            setState(() => _selected = null);
                            await _reloadFromDb();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Customer removed.')),
                            );
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = shouldShowMasterDetailSideBySide(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Owners'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                Expanded(flex: 5, child: _buildListPane()),
                const VerticalDivider(width: 1),
                Expanded(flex: 5, child: _buildDetailPane()),
              ],
            )
          : _selected == null
              ? _buildListPane()
              : Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _selected = null),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to list'),
                      ),
                    ),
                    Expanded(child: _buildDetailPane()),
                  ],
                ),
    );
  }
}
