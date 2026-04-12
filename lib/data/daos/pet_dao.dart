import 'package:floor/floor.dart';

import '../entities/pet.dart';

/// Data access for [Pet] rows.
@dao
abstract class PetDao {
  @Query('SELECT * FROM pets ORDER BY name ASC')
  Future<List<Pet>> findAll();

  @insert
  Future<void> insertPet(Pet pet);

  @Update()
  Future<void> updatePet(Pet pet);

  @delete
  Future<void> deletePet(Pet pet);
}
