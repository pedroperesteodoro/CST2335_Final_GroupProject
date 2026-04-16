import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// Loads the correct translation JSON file based on the device locale.
/// Usage anywhere in the app:
///   AppLocalizations.of(context)!.translate('key')!
class AppLocalizations {
  final Locale locale;

  /// The locale this instance was loaded for.
  AppLocalizations(this.locale);

  /// Returns the [AppLocalizations] instance for the current [BuildContext].
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }


  /// The delegate used by [MaterialApp] to load this class.
  static const LocalizationsDelegate<AppLocalizations> delegate =
        _AppLocalizationsDelegate();


  /// Internal map of translation keys to translated strings.
  late Map<String, String> _strings;


  /// Loads the JSON translation file for the current locale from assets.
  /// Called automatically by [_AppLocalizationsDelegate.load].
  Future<bool> load() async {
    final jsonString = await rootBundle.loadString(
        'assets/translations/${locale.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _strings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  /// Returns the translated string for the given [key].
  /// Returns null if the key does not exist in the translation file.
  String? translate(String key) => _strings[key];
}

/// Tells Flutter how to load [AppLocalizations] for a given locale.
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  /// Supported language codes — must match your JSON file names.
  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr'].contains(locale.languageCode);

   /// Loads and returns an [AppLocalizations] instance for [locale].
  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
  }

