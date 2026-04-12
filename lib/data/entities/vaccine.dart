import 'package:floor/floor.dart';

/// Row in SQLite for a **vaccine** inventory record.
@Entity(tableName: 'vaccines')
class Vaccine {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Vaccine product name.
  final String name;

  /// Dosage description (e.g. `0.5 mL`).
  final String dosage;

  /// Manufacturer lot number.
  final String lotNumber;

  /// Expiration as text (e.g. `YYYY-MM-DD`).
  final String expirationDate;

  Vaccine({
    this.id,
    required this.name,
    required this.dosage,
    required this.lotNumber,
    required this.expirationDate,
  });
}
