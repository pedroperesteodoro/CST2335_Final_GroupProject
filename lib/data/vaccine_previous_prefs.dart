import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'entities/vaccine.dart';

/// This helper saves the last vaccine the user added.
/// We use encrypted shared preferences so values are stored safely.
class VaccinePreviousPrefs {
  // Private constructor so nobody creates this helper class.
  VaccinePreviousPrefs._();

  // One shared encrypted preferences object.
  static final EncryptedSharedPreferences _enc = EncryptedSharedPreferences();

  // Keys used to save each vaccine field.
  static const _kName = 'vaccine_last_name';
  static const _kDosage = 'vaccine_last_dosage';
  static const _kLot = 'vaccine_last_lot';
  static const _kExp = 'vaccine_last_exp';

  // Check if we already saved a previous vaccine.
  static Future<bool> hasPrevious() async {
    final n = (await _enc.getString(_kName)).trim();
    return n.isNotEmpty;
  }

  // Load saved fields and return them as a Vaccine template.
  // This template is used to prefill the add form.
  static Future<Vaccine> loadTemplate() async {
    return Vaccine(
      name: (await _enc.getString(_kName)).trim(),
      dosage: (await _enc.getString(_kDosage)).trim(),
      lotNumber: (await _enc.getString(_kLot)).trim(),
      expirationDate: (await _enc.getString(_kExp)).trim(),
    );
  }

  // Save fields from the latest added vaccine.
  // Next time the user can choose "Copy previous".
  static Future<void> saveLastCreated(Vaccine v) async {
    await _enc.setString(_kName, v.name.trim());
    await _enc.setString(_kDosage, v.dosage.trim());
    await _enc.setString(_kLot, v.lotNumber.trim());
    await _enc.setString(_kExp, v.expirationDate.trim());
  }
}
