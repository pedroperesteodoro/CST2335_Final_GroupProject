import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/pet_owner.dart';

/// Saves and restores the last entered [PetOwner] using encrypted storage.
class PreferencesHelper {
  static final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  static const String _keyFirstName = 'prev_firstName';
  static const String _keyLastName = 'prev_lastName';
  static const String _keyAddress = 'prev_address';
  static const String _keyDob = 'prev_dob';
  static const String _keyInsurance = 'prev_insurance';

  /// Saves all fields of [owner] to encrypted shared preferences.
  static Future<void> saveOwner(PetOwner owner) async {
    await _prefs.setString(_keyFirstName, owner.firstName);
    await _prefs.setString(_keyLastName, owner.lastName);
    await _prefs.setString(_keyAddress, owner.address);
    await _prefs.setString(_keyDob, owner.dateOfBirth);
    await _prefs.setString(_keyInsurance, owner.insuranceNumber);
  }

  /// Returns the previously saved owner fields as a string map.
  static Future<Map<String, String>> getOwner() async {
    return {
      'firstName': await _prefs.getString(_keyFirstName) ?? '',
      'lastName': await _prefs.getString(_keyLastName) ?? '',
      'address': await _prefs.getString(_keyAddress) ?? '',
      'dateOfBirth': await _prefs.getString(_keyDob) ?? '',
      'insuranceNumber': await _prefs.getString(_keyInsurance) ?? '',
    };
  }

  /// Returns true if a previous owner has been saved.
  static Future<bool> hasPreviousOwner() async {
    final name = await _prefs.getString(_keyFirstName);
    return name.isNotEmpty;
  }

  /// Removes all saved owner fields from encrypted storage.
  static Future<void> clear() async {
    // ✅ FIX: Use setString with empty string instead of remove
    await _prefs.setString(_keyFirstName, '');
    await _prefs.setString(_keyLastName, '');
    await _prefs.setString(_keyAddress, '');
    await _prefs.setString(_keyDob, '');
    await _prefs.setString(_keyInsurance, '');
  }
}