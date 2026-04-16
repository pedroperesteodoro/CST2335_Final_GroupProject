import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';

import 'data/database_holder.dart';
import 'screens/pet_owner_screen.dart';
import 'screens/pet_screen.dart';
import 'screens/vaccine_screen.dart';
import 'screens/veterinarian_screen.dart';

/// App entry: initializes SQLite (Floor) before any screen touches the DAOs.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHolder.init();
  runApp(MyApp());
}

/// Root widget for the CST2335 group project (veterinary clinic modules).
  class MyApp extends StatefulWidget {
    const MyApp({super.key});

    static void setLocale(BuildContext context, Locale newLocale) {
      MyAppState? state = context.findRootAncestorStateOfType<MyAppState>();
      state?.changeLanguage(newLocale);
    }

    @override
    State<MyApp> createState() => MyAppState();
  }

  class MyAppState extends State<MyApp> {
    Locale _locale = const Locale('en');

    void changeLanguage(Locale newLocale) {
      setState(() => _locale = newLocale);
    }

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'FinalProject',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const MainMenuPage(),
      );
    }
  }

/// Main screen: four buttons — each opens one teammate’s topic (implemented here as base scaffolds).
///
/// Per course notes on responsive layouts, this menu stays a single column;
/// master–detail applies on each feature page when `(width > height) && (width > 720)`.
class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const PetOwnerScreen()),
                    );
                  },
                  child: const Text('Pet Owners'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const PetScreen()),
                    );
                  },
                  child: const Text('Pets'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const VaccineScreen()),
                    );
                  },
                  child: const Text('Vaccines'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const VeterinarianScreen()),
                    );
                  },
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
