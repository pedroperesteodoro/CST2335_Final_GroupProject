import 'package:floor/floor.dart';

import '../entities/veterinarian.dart';

/// Data access for [Veterinarian] rows.
@dao
abstract class VeterinarianDao {
  @Query('SELECT * FROM veterinarians ORDER BY name ASC')
  Future<List<Veterinarian>> findAll();

  @insert
  Future<void> insertVeterinarian(Veterinarian veterinarian);

  @Update()
  Future<void> updateVeterinarian(Veterinarian veterinarian);

  @delete
  Future<void> deleteVeterinarian(Veterinarian veterinarian);
}
