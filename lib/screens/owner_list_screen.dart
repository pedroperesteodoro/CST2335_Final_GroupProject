import 'package:flutter/material.dart';
import '../database/owner_database.dart';
import '../models/pet_owner.dart';
import '../utils/app_localizations.dart';
import 'owner_form_screen.dart';

/// Displays a searchable [ListView] of all [PetOwner] records.
///
/// - Phone: tapping an owner navigates full-screen to [OwnerFormScreen].
/// - Tablet (width > 600): details appear in a side panel beside the list.
///
/// Requirements covered:
///   ✅ #1  ListView
///   ✅ #2  TextField + button to add items
///   ✅ #3  Database persistence
///   ✅ #4  Phone vs tablet layout
///   ✅ #5  Snackbar + AlertDialog
///   ✅ #7  ActionBar with instructions AlertDialog
class OwnerListScreen extends StatefulWidget {
  /// Creates the [OwnerListScreen].
  const OwnerListScreen({super.key});

  @override
  State<OwnerListScreen> createState() => _OwnerListScreenState();
}

class _OwnerListScreenState extends State<OwnerListScreen> {
  final OwnerDatabase _db = OwnerDatabase.instance;
  final TextEditingController _searchController = TextEditingController();

  List<PetOwner> _owners = [];
  PetOwner? _selectedOwner;

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Data ─────────────────────────────────────────────────────────────────

  Future<void> _loadOwners() async {
    final owners = await _db.getAllOwners();
    if (mounted) setState(() => _owners = owners);
  }

  Future<void> _searchOwners(String query) async {
    final owners = query.isEmpty
        ? await _db.getAllOwners()
        : await _db.searchOwners(query);
    if (mounted) setState(() => _owners = owners);
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _addOwner(bool isTablet) async {
    if (isTablet) {
      setState(() => _selectedOwner = null);
    }
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const OwnerFormScreen(isEdit: false),
      ),
    );
    _handleResult(result);
  }

  Future<void> _openOwner(PetOwner owner, bool isTablet) async {
    if (isTablet) {
      setState(() => _selectedOwner = owner);
      return;
    }
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerFormScreen(isEdit: true, owner: owner),
      ),
    );
    _handleResult(result);
  }

  void _handleResult(String? result) {
    if (result == null) return;
    _loadOwners();
    setState(() => _selectedOwner = null);

    final l = AppLocalizations.of(context);
    String msg = '';
    if (result == 'added') msg = l.translate('ownerAdded');
    if (result == 'updated') msg = l.translate('ownerUpdated');
    if (result == 'deleted') msg = l.translate('ownerDeleted');
    if (msg.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showInstructions() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.translate('instructions')),
        content: Text(l.translate('instructionsText')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.translate('gotIt')),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.translate('petOwners')),
        // Requirement #7: ActionBar with instructions
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'instructions') _showInstructions();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'instructions',
                child: Row(
                  children: [
                    const Icon(Icons.help_outline, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(l.translate('instructions')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isTablet
          ? _buildTabletLayout(l, isTablet)
          : _buildPhoneLayout(l, isTablet),
    );
  }

  Widget _buildPhoneLayout(AppLocalizations l, bool isTablet) {
    return Column(
      children: [
        _buildSearchBar(l, isTablet),
        Expanded(child: _buildList(l, isTablet)),
      ],
    );
  }

  Widget _buildTabletLayout(AppLocalizations l, bool isTablet) {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: Column(
            children: [
              _buildSearchBar(l, isTablet),
              Expanded(child: _buildList(l, isTablet)),
            ],
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: _selectedOwner == null
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  l.translate('selectOwner'),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          )
              : OwnerFormScreen(
            key: ValueKey(_selectedOwner!.id),
            isEdit: true,
            owner: _selectedOwner,
            isEmbedded: true,
            onResult: _handleResult,
          ),
        ),
      ],
    );
  }

  // Requirement #2: TextField + button
  Widget _buildSearchBar(AppLocalizations l, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l.translate('searchHint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadOwners();
                    setState(() {});
                  },
                )
                    : null,
              ),
              onChanged: (v) {
                _searchOwners(v);
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D9A),
              padding: const EdgeInsets.all(16),
              shape: const CircleBorder(),
            ),
            onPressed: () => _addOwner(isTablet),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Requirement #1: ListView
  Widget _buildList(AppLocalizations l, bool isTablet) {
    if (_owners.isEmpty) {
      return Center(
        child: Text(
          l.translate('noOwners'),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[500], fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      itemCount: _owners.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final owner = _owners[index];
        final isSelected = isTablet && _selectedOwner?.id == owner.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: isSelected ? const Color(0xFFE3F2FD) : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2E7D9A),
              child: Text(
                owner.firstName[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              owner.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(owner.address),
            trailing: owner.insuranceNumber.isNotEmpty
                ? const Icon(Icons.verified_user,
                color: Color(0xFF2E7D9A), size: 20)
                : const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _openOwner(owner, isTablet),
          ),
        );
      },
    );
  }
}