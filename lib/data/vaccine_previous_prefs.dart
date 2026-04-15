import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'entities/vaccine.dart';

/// Stores field values from the last **successfully added** vaccine using [EncryptedSharedPreferences].
class VaccinePreviousPrefs {
  VaccinePreviousPrefs._();

  static final EncryptedSharedPreferences _enc = EncryptedSharedPreferences();

  static const _kName = 'vaccine_last_name';
  static const _kDosage = 'vaccine_last_dosage';
  static const _kLot = 'vaccine_last_lot';
  static const _kExp = 'vaccine_last_exp';

  static Future<bool> hasPrevious() async {
    final n = (await _enc.getString(_kName)).trim();
    return n.isNotEmpty;
  }

  static Future<Vaccine> loadTemplate() async {
    return Vaccine(
      name: (await _enc.getString(_kName)).trim(),
      dosage: (await _enc.getString(_kDosage)).trim(),
      lotNumber: (await _enc.getString(_kLot)).trim(),
      expirationDate: (await _enc.getString(_kExp)).trim(),
    );
  }

  static Future<void> saveLastCreated(Vaccine v) async {
    await _enc.setString(_kName, v.name.trim());
    await _enc.setString(_kDosage, v.dosage.trim());
    await _enc.setString(_kLot, v.lotNumber.trim());
    await _enc.setString(_kExp, v.expirationDate.trim());
  }
}
