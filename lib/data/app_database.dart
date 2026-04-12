import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'daos/pet_dao.dart';
import 'daos/pet_owner_dao.dart';
import 'daos/vaccine_dao.dart';
import 'daos/veterinarian_dao.dart';
import 'entities/pet.dart';
import 'entities/pet_owner.dart';
import 'entities/vaccine.dart';
import 'entities/veterinarian.dart';

/// Generated Floor implementation — create with:
/// `dart run build_runner build --delete-conflicting-outputs`
part 'app_database.g.dart';

/// Single SQLite database for all four modules (see SQLite.txt: one @Database, many entities).
@Database(version: 1, entities: [PetOwner, Pet, Vaccine, Veterinarian])
abstract class AppDatabase extends FloorDatabase {
  PetOwnerDao get petOwnerDao;

  PetDao get petDao;

  VaccineDao get vaccineDao;

  VeterinarianDao get veterinarianDao;
}
