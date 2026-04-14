import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Provides translated strings for American and British English.
///
/// Register [AppLocalizationsDelegate] in [MaterialApp.localizationsDelegates]
/// and retrieve via [AppLocalizations.of(context)].
class AppLocalizations {
  /// The locale this instance was loaded for.
  final Locale locale;
  Map<String, String> _strings = {};

  /// Creates an [AppLocalizations] for [locale].
  AppLocalizations(this.locale);

  /// Returns the nearest [AppLocalizations] from the widget tree.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Loads the JSON translation file for the current locale.
  Future<void> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/${locale.languageCode}-${locale.countryCode}.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _strings = jsonMap.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      // Fall back to empty map — keys will show as-is
      _strings = {};
    }
  }

  /// Returns the localized string for [key], or [key] if not found.
  String translate(String key) => _strings[key] ?? key;
}

/// Creates and loads an [AppLocalizations] instance for the given locale.
class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  /// Creates an [AppLocalizationsDelegate].
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' &&
          (locale.countryCode == 'US' || locale.countryCode == 'GB');

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final loc = AppLocalizations(locale);
    await loc.load();
    return loc;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}