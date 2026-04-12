import 'package:floor/floor.dart';

/// Row in SQLite for a veterinary **customer** (pet owner).
///
/// Maps to table `pet_owners`. Matches the assignment: names, address, DOB,
/// optional insurance #.
@Entity(tableName: 'pet_owners')
class PetOwner {
  /// Surrogate primary key; null on insert so Floor can auto-generate.
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Customer first name (required in the full assignment form).
  final String firstName;

  /// Customer last name.
  final String lastName;

  /// Street / mailing address as a single string for this scaffold.
  final String address;

  /// Date of birth stored as text (e.g. `YYYY-MM-DD`) for simplicity.
  final String dateOfBirth;

  /// Optional pet insurance number; may be null or empty.
  final String? insuranceNumber;

  PetOwner({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.dateOfBirth,
    this.insuranceNumber,
  });
}
