import 'package:floor/floor.dart';

import '../entities/pet_owner.dart';
///Vaibhav Tanwar
/// Data access for [PetOwner] rows (course pattern: @Query / @insert / @update / @delete).
@dao
abstract class PetOwnerDao {
  /// Load every owner row (used on screen open / after changes).
  @Query('SELECT * FROM pet_owners ORDER BY lastName ASC, firstName ASC')
  Future<List<PetOwner>> findAll();

  /// Insert a new owner; generated id is assigned by SQLite.
  @insert
  Future<void> insertPetOwner(PetOwner petOwner);

  /// Persist edits to an existing row (id must be non-null).
  @Update()
  Future<void> updatePetOwner(PetOwner petOwner);

  /// Remove one row from the database.
  @delete
  Future<void> deletePetOwner(PetOwner petOwner);
}
