import 'package:floor/floor.dart';

/// Row in SQLite for an animal **patient**.
///
/// Maps to table `pets`. `ownerId` can reference [PetOwner.id] when you wire FK logic.
@Entity(tableName: 'pets')
class Pet {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Animal name.
  final String name;

  /// Birthday as text (e.g. `YYYY-MM-DD`).
  final String birthday;

  /// e.g. cat, dog, bird.
  final String species;

  /// Stored as US spelling in DB column; UI can localize display.
  final String colour;

  /// ID of owning customer (see [PetOwner]); 0 if unknown in this base.
  final int ownerId;

  Pet({
    this.id,
    required this.name,
    required this.birthday,
    required this.species,
    required this.colour,
    required this.ownerId,
  });
}
