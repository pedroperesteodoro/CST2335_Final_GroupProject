import 'package:floor/floor.dart';

/// Row in SQLite for a **veterinarian** staff record.
@Entity(tableName: 'veterinarians')
class Veterinarian {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;

  /// Birthday as text.
  final String birthday;

  /// Clinic / contact address.
  final String address;

  /// Graduated-from university name.
  final String university;

  Veterinarian({
    this.id,
    required this.name,
    required this.birthday,
    required this.address,
    required this.university,
  });
}
