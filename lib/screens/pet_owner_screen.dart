import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/database_holder.dart';
import '../data/entities/pet_owner.dart';
import '../widgets/reactive_layout.dart';

class PetOwnerScreen extends StatefulWidget {
  const PetOwnerScreen({super.key});

  @override
  State<PetOwnerScreen> createState() => _PetOwnerScreenState();
}

class _PetOwnerScreenState extends State<PetOwnerScreen> {
  List<PetOwner> _rows = [];
  PetOwner? _selected;


  final _storage = const FlutterSecureStorage();

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

  /// Reloads list from SQLite and updates the UI.
  Future<void> _reloadFromDb() async {
    final dao = DatabaseHolder.instance.petOwnerDao;
    final list = await dao.findAll();
    if (!mounted) return;
    setState(() => _rows = list);
  }

  Future<void> _saveToEncryptedStorage() async {
    await _storage.write(key: 'last_first', value: _first.text);
    await _storage.write(key: 'last_last', value: _last.text);
    await _storage.write(key: 'last_address', value: _address.text);
    await _storage.write(key: 'last_dob', value: _dob.text);
  }

  Future<void> _loadFromEncryptedStorage() async {
    _first.text = await _storage.read(key: 'last_first') ?? "";
    _last.text = await _storage.read(key: 'last_last') ?? "";
    _address.text = await _storage.read(key: 'last_address') ?? "";
    _dob.text = await _storage.read(key: 'last_dob') ?? "";

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fields copied from previous customer.')),
    );
  }

  /// Add Logic with Requirement #5 (AlertDialog & Snackbar)
  Future<void> _onAddPressed() async {
    if (_first.text.isEmpty || _last.text.isEmpty || _address.text.isEmpty || _dob.text.isEmpty) {
      _showSimpleDialog('Missing Data', 'Please fill all fields except Insurance.');
      return;
    }

    final row = PetOwner(
      firstName: _first.text,
      lastName: _last.text,
      address: _address.text,
      dateOfBirth: _dob.text,
      insuranceNumber: _insurance.text.isEmpty ? null : _insurance.text,
    );

    await DatabaseHolder.instance.petOwnerDao.insertPetOwner(row);
    await _saveToEncryptedStorage(); // Save for future copying

    _clearFields();
    await _reloadFromDb();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer successfully added!')),
    );
  }

  /// Logic to update an existing customer.
  Future<void> _onUpdatePressed() async {
    if (_selected == null) return;

    final updated = PetOwner(
      id: _selected!.id, // Keep the same ID to overwrite the row
      firstName: _first.text,
      lastName: _last.text,
      address: _address.text,
      dateOfBirth: _dob.text,
      insuranceNumber: _insurance.text,
    );

    await DatabaseHolder.instance.petOwnerDao.updatePetOwner(updated);
    await _reloadFromDb();
    setState(() => _selected = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer information updated.')),
    );
  }

  void _clearFields() {
    _first.clear(); _last.clear(); _address.clear(); _dob.clear(); _insurance.clear();
  }

  void _showSimpleDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
      ),
    );
  }

  void _showHelpDialog() {
    _showSimpleDialog(
      'Pet Owner Instructions',
      '1. Use the form to enter data.\n2. Tap "Add" to save.\n3. Tap "Copy Previous" to reload last entry.\n4. Select a name from the list to Update or Delete.',
    );
  }

  Widget _buildListPane() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(controller: _first, decoration: const InputDecoration(labelText: 'First Name')),
              TextField(controller: _last, decoration: const InputDecoration(labelText: 'Last Name')),
              TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: _dob, decoration: const InputDecoration(labelText: 'Date of Birth')),
              TextField(controller: _insurance, decoration: const InputDecoration(labelText: 'Insurance #')),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _onAddPressed, child: const Text('Add')),
                  OutlinedButton(onPressed: _loadFromEncryptedStorage, child: const Text('Copy Previous')),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _rows.length,
            itemBuilder: (context, i) {
              final r = _rows[i];
              return ListTile(
                title: Text('${r.lastName}, ${r.firstName}'),
                subtitle: Text(r.address),
                onTap: () {
                  setState(() => _selected = r);
                  // Populate fields for editing
                  _first.text = r.firstName;
                  _last.text = r.lastName;
                  _address.text = r.address;
                  _dob.text = r.dateOfBirth;
                  _insurance.text = r.insuranceNumber ?? "";
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPane() {
    if (_selected == null) return const Center(child: Text('Select a customer to view details.'));
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Customer Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: _onUpdatePressed, child: const Text('Update')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                onPressed: () async {
                  await DatabaseHolder.instance.petOwnerDao.deletePetOwner(_selected!);
                  setState(() => _selected = null);
                  _reloadFromDb();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed.')));
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        title: const Text('Pet Owners List'),
        actions: [IconButton(icon: const Icon(Icons.help_outline), onPressed: _showHelpDialog)],
      ),
      body: wide
          ? Row(children: [Expanded(child: _buildListPane()), const VerticalDivider(), Expanded(child: _buildDetailPane())])
          : (_selected == null ? _buildListPane() : _buildDetailPane()),
    );
  }
}