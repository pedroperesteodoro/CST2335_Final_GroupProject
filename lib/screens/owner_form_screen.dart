import 'package:flutter/material.dart';
import '../database/owner_database.dart';
import '../models/pet_owner.dart';
import '../utils/app_localizations.dart';
import '../utils/preferences_helper.dart';

/// Form for adding, viewing, updating, and deleting a [PetOwner].
///
/// Used as a full-screen page on phones, or an embedded widget on tablets.
///
/// Requirements covered:
///   ✅ #2  TextField inputs with validation
///   ✅ #3  Database insert / update / delete
///   ✅ #5  Snackbar + AlertDialog (delete confirm + copy previous)
///   ✅ #6  EncryptedSharedPreferences for copy-previous-entry feature
///   ✅ #8  Localized labels via [AppLocalizations]
///   ✅ #10 Professional layout
class OwnerFormScreen extends StatefulWidget {
  /// True when editing an existing owner; false when adding a new one.
  final bool isEdit;

  /// The owner to display/edit. Must be provided when [isEdit] is true.
  final PetOwner? owner;

  /// When true this widget is embedded in the tablet side panel (no Scaffold).
  final bool isEmbedded;

  /// Callback for embedded mode — receives 'added', 'updated', or 'deleted'.
  final void Function(String result)? onResult;

  /// Creates an [OwnerFormScreen].
  const OwnerFormScreen({
    super.key,
    required this.isEdit,
    this.owner,
    this.isEmbedded = false,
    this.onResult,
  });

  @override
  State<OwnerFormScreen> createState() => _OwnerFormScreenState();
}

class _OwnerFormScreenState extends State<OwnerFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final OwnerDatabase _db = OwnerDatabase.instance;

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _insuranceCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _dobCtrl = TextEditingController();
    _insuranceCtrl = TextEditingController();

    if (widget.isEdit && widget.owner != null) {
      _fillFromOwner(widget.owner!);
    } else {
      // Requirement #6: offer to copy previous entry on add
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _offerCopyPrevious());
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _addressCtrl.dispose();
    _dobCtrl.dispose();
    _insuranceCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _fillFromOwner(PetOwner o) {
    _firstNameCtrl.text = o.firstName;
    _lastNameCtrl.text = o.lastName;
    _addressCtrl.text = o.address;
    _dobCtrl.text = o.dateOfBirth;
    _insuranceCtrl.text = o.insuranceNumber;
  }

  void _fillFromMap(Map<String, String> m) {
    _firstNameCtrl.text = m['firstName'] ?? '';
    _lastNameCtrl.text = m['lastName'] ?? '';
    _addressCtrl.text = m['address'] ?? '';
    _dobCtrl.text = m['dateOfBirth'] ?? '';
    _insuranceCtrl.text = m['insuranceNumber'] ?? '';
  }

  PetOwner _buildOwner() {
    return PetOwner(
      id: widget.isEdit ? widget.owner!.id : null,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      dateOfBirth: _dobCtrl.text.trim(),
      insuranceNumber: _insuranceCtrl.text.trim(),
    );
  }

  void _finish(String result) {
    if (widget.isEmbedded) {
      widget.onResult?.call(result);
    } else {
      Navigator.pop(context, result);
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Requirement #6: Show AlertDialog offering to copy EncryptedSharedPreferences data.
  Future<void> _offerCopyPrevious() async {
    final hasPrev = await PreferencesHelper.hasPreviousOwner();
    if (!hasPrev || !mounted) return;

    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.translate('copyPrevious')),
        content: Text(l.translate('copyMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.translate('no')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D9A),
            ),
            onPressed: () async {
              final prev = await PreferencesHelper.getOwner();
              if (mounted) {
                setState(() => _fillFromMap(prev));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.translate('copiedSnackbar'))),
                );
              }
            },
            child: Text(l.translate('yes')),
          ),
        ],
      ),
    );
  }

  /// Validates the form, saves to DB, and stores in EncryptedSharedPreferences.
  Future<void> _saveOwner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final owner = _buildOwner();
      if (widget.isEdit) {
        await _db.updateOwner(owner);
        await PreferencesHelper.saveOwner(owner);
        _finish('updated');
      } else {
        final newId = await _db.insertOwner(owner);
        await PreferencesHelper.saveOwner(owner.copyWith(id: newId));
        _finish('added');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Shows a confirmation AlertDialog then deletes the owner from the DB.
  Future<void> _deleteOwner() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.translate('deleteConfirm')),
        content: Text(l.translate('deleteMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.translate('cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.translate('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _db.deleteOwner(widget.owner!.id!);
      _finish('deleted');
    }
  }

  /// Opens a date picker and populates the DOB field.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && mounted) {
      final y = picked.year.toString();
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      _dobCtrl.text = '$y-$m-$d';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title =
    widget.isEdit ? 'Edit Owner' : l.translate('addOwner');
    final formContent = _buildFormContent(l);

    // Embedded mode (tablet side panel) — no Scaffold
    if (widget.isEmbedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF2E7D9A).withAlpha(20),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: SingleChildScrollView(child: formContent)),
        ],
      );
    }

    // Full-screen mode (phone)
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(child: formContent),
    );
  }

  Widget _buildFormContent(AppLocalizations l) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First Name
            TextFormField(
              controller: _firstNameCtrl,
              decoration: InputDecoration(
                labelText: l.translate('firstName'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.translate('fieldRequired')
                  : null,
            ),
            const SizedBox(height: 14),

            // Last Name
            TextFormField(
              controller: _lastNameCtrl,
              decoration: InputDecoration(
                labelText: l.translate('lastName'),
                prefixIcon: const Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.translate('fieldRequired')
                  : null,
            ),
            const SizedBox(height: 14),

            // Address
            TextFormField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                labelText: l.translate('address'),
                prefixIcon: const Icon(Icons.home_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.translate('fieldRequired')
                  : null,
            ),
            const SizedBox(height: 14),

            // Date of Birth — tapping opens date picker
            TextFormField(
              controller: _dobCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: l.translate('dateOfBirth'),
                prefixIcon: const Icon(Icons.cake_outlined),
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
              ),
              onTap: _pickDate,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.translate('fieldRequired')
                  : null,
            ),
            const SizedBox(height: 14),

            // Insurance Number (optional — no validator)
            TextFormField(
              controller: _insuranceCtrl,
              decoration: InputDecoration(
                labelText: l.translate('insuranceNumber'),
                prefixIcon: const Icon(Icons.verified_user_outlined),
              ),
            ),
            const SizedBox(height: 28),

            // Action buttons
            if (widget.isEdit) ...[
              ElevatedButton(
                onPressed: _isSaving ? null : _saveOwner,
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : Text(l.translate('update')),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isSaving ? null : _deleteOwner,
                child: Text(l.translate('delete')),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _isSaving ? null : _saveOwner,
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : Text(l.translate('submit')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}