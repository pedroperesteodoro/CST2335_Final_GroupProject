import 'package:floor/floor.dart';

import '../entities/vaccine.dart';

/// This DAO file only talks to the vaccines table.
/// It does not handle UI.
@dao
abstract class VaccineDao {
  // Get all vaccines from the database.
  // We sort by expiration date so the list has a stable order.
  @Query('SELECT * FROM vaccines ORDER BY expirationDate ASC')
  Future<List<Vaccine>> findAll();

  // Add one new vaccine row to the database.
  @insert
  Future<void> insertVaccine(Vaccine vaccine);

  // Update one existing vaccine row in the database.
  @Update()
  Future<void> updateVaccine(Vaccine vaccine);

  // Delete one vaccine row from the database.
  @delete
  Future<void> deleteVaccine(Vaccine vaccine);
}
