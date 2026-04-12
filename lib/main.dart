import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget for the CST2335 group project (veterinary clinic modules).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinalProject',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainMenuPage(),
    );
  }
}

/// Main screen: four buttons, each opens a landing area for one team topic.
///
/// Per course notes on responsive layouts, this menu stays a single column;
/// master–detail (list beside details) applies on feature pages when
/// `(width > height) && (width > 720)`, not on this launcher.
class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  /// Routes to a placeholder page for a module until that feature is merged.
  void _openModule(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ModuleLandingPage(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinalProject'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                FilledButton(
                  onPressed: () => _openModule(context, 'Pet Owners'),
                  child: const Text('Pet Owners'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _openModule(context, 'Pets'),
                  child: const Text('Pets'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _openModule(context, 'Vaccines'),
                  child: const Text('Vaccines'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _openModule(context, 'Veterinarians'),
                  child: const Text('Veterinarians'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Temporary landing page for a module. Replace with each member’s real screen.
class ModuleLandingPage extends StatelessWidget {
  /// Title shown in the app bar (which module this is).
  const ModuleLandingPage({required this.title, super.key});

  /// Display name for this branch of the app.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$title — implementation goes here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
