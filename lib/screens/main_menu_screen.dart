import 'package:flutter/material.dart';
import 'owner_list_screen.dart';

/// The main landing screen shown when the application launches.
///
/// Contains 4 buttons — one per team member's section.
/// Only the Pet Owners button is active; teammates fill in the rest.
class MainMenuScreen extends StatelessWidget {
  /// Creates the [MainMenuScreen].
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Management System'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.local_hospital,
                  size: 72, color: Color(0xFF2E7D9A)),
              const SizedBox(height: 16),
              const Text(
                'Veterinary Management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // ── Your section ──────────────────────────────────────
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Pet Owners',
                    style: TextStyle(fontSize: 16)),
                onPressed: () => Navigator.push(
                  context,
                   MaterialPageRoute(
                    builder: (_) => const OwnerListScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Teammates' sections (they replace these) ──────────
              OutlinedButton.icon(
                icon: const Icon(Icons.pets),
                label: const Text('Pets', style: TextStyle(fontSize: 16)),
                onPressed: null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.vaccines),
                label: const Text('Vaccines',
                    style: TextStyle(fontSize: 16)),
                onPressed: null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.medical_services),
                label: const Text('Veterinarians',
                    style: TextStyle(fontSize: 16)),
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}