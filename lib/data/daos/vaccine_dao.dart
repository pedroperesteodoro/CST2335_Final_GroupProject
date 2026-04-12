import 'package:floor/floor.dart';

import '../entities/vaccine.dart';

/// Data access for [Vaccine] rows.
@dao
abstract class VaccineDao {
  @Query('SELECT * FROM vaccines ORDER BY expirationDate ASC')
  Future<List<Vaccine>> findAll();

  @insert
  Future<void> insertVaccine(Vaccine vaccine);

  @Update()
  Future<void> updateVaccine(Vaccine vaccine);

  @delete
  Future<void> deleteVaccine(Vaccine vaccine);
}
