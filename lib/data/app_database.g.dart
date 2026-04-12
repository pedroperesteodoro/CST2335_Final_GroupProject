// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PetOwnerDao? _petOwnerDaoInstance;

  PetDao? _petDaoInstance;

  VaccineDao? _vaccineDaoInstance;

  VeterinarianDao? _veterinarianDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `pet_owners` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `address` TEXT NOT NULL, `dateOfBirth` TEXT NOT NULL, `insuranceNumber` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `pets` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `birthday` TEXT NOT NULL, `species` TEXT NOT NULL, `colour` TEXT NOT NULL, `ownerId` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `vaccines` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `dosage` TEXT NOT NULL, `lotNumber` TEXT NOT NULL, `expirationDate` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `veterinarians` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `birthday` TEXT NOT NULL, `address` TEXT NOT NULL, `university` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PetOwnerDao get petOwnerDao {
    return _petOwnerDaoInstance ??= _$PetOwnerDao(database, changeListener);
  }

  @override
  PetDao get petDao {
    return _petDaoInstance ??= _$PetDao(database, changeListener);
  }

  @override
  VaccineDao get vaccineDao {
    return _vaccineDaoInstance ??= _$VaccineDao(database, changeListener);
  }

  @override
  VeterinarianDao get veterinarianDao {
    return _veterinarianDaoInstance ??=
        _$VeterinarianDao(database, changeListener);
  }
}

class _$PetOwnerDao extends PetOwnerDao {
  _$PetOwnerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _petOwnerInsertionAdapter = InsertionAdapter(
            database,
            'pet_owners',
            (PetOwner item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth,
                  'insuranceNumber': item.insuranceNumber
                }),
        _petOwnerUpdateAdapter = UpdateAdapter(
            database,
            'pet_owners',
            ['id'],
            (PetOwner item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth,
                  'insuranceNumber': item.insuranceNumber
                }),
        _petOwnerDeletionAdapter = DeletionAdapter(
            database,
            'pet_owners',
            ['id'],
            (PetOwner item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth,
                  'insuranceNumber': item.insuranceNumber
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PetOwner> _petOwnerInsertionAdapter;

  final UpdateAdapter<PetOwner> _petOwnerUpdateAdapter;

  final DeletionAdapter<PetOwner> _petOwnerDeletionAdapter;

  @override
  Future<List<PetOwner>> findAll() async {
    return _queryAdapter.queryList(
        'SELECT * FROM pet_owners ORDER BY lastName ASC, firstName ASC',
        mapper: (Map<String, Object?> row) => PetOwner(
            id: row['id'] as int?,
            firstName: row['firstName'] as String,
            lastName: row['lastName'] as String,
            address: row['address'] as String,
            dateOfBirth: row['dateOfBirth'] as String,
            insuranceNumber: row['insuranceNumber'] as String?));
  }

  @override
  Future<void> insertPetOwner(PetOwner petOwner) async {
    await _petOwnerInsertionAdapter.insert(petOwner, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePetOwner(PetOwner petOwner) async {
    await _petOwnerUpdateAdapter.update(petOwner, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePetOwner(PetOwner petOwner) async {
    await _petOwnerDeletionAdapter.delete(petOwner);
  }
}

class _$PetDao extends PetDao {
  _$PetDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _petInsertionAdapter = InsertionAdapter(
            database,
            'pets',
            (Pet item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'species': item.species,
                  'colour': item.colour,
                  'ownerId': item.ownerId
                }),
        _petUpdateAdapter = UpdateAdapter(
            database,
            'pets',
            ['id'],
            (Pet item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'species': item.species,
                  'colour': item.colour,
                  'ownerId': item.ownerId
                }),
        _petDeletionAdapter = DeletionAdapter(
            database,
            'pets',
            ['id'],
            (Pet item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'species': item.species,
                  'colour': item.colour,
                  'ownerId': item.ownerId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Pet> _petInsertionAdapter;

  final UpdateAdapter<Pet> _petUpdateAdapter;

  final DeletionAdapter<Pet> _petDeletionAdapter;

  @override
  Future<List<Pet>> findAll() async {
    return _queryAdapter.queryList('SELECT * FROM pets ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => Pet(
            id: row['id'] as int?,
            name: row['name'] as String,
            birthday: row['birthday'] as String,
            species: row['species'] as String,
            colour: row['colour'] as String,
            ownerId: row['ownerId'] as int));
  }

  @override
  Future<void> insertPet(Pet pet) async {
    await _petInsertionAdapter.insert(pet, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePet(Pet pet) async {
    await _petUpdateAdapter.update(pet, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePet(Pet pet) async {
    await _petDeletionAdapter.delete(pet);
  }
}

class _$VaccineDao extends VaccineDao {
  _$VaccineDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _vaccineInsertionAdapter = InsertionAdapter(
            database,
            'vaccines',
            (Vaccine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'dosage': item.dosage,
                  'lotNumber': item.lotNumber,
                  'expirationDate': item.expirationDate
                }),
        _vaccineUpdateAdapter = UpdateAdapter(
            database,
            'vaccines',
            ['id'],
            (Vaccine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'dosage': item.dosage,
                  'lotNumber': item.lotNumber,
                  'expirationDate': item.expirationDate
                }),
        _vaccineDeletionAdapter = DeletionAdapter(
            database,
            'vaccines',
            ['id'],
            (Vaccine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'dosage': item.dosage,
                  'lotNumber': item.lotNumber,
                  'expirationDate': item.expirationDate
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Vaccine> _vaccineInsertionAdapter;

  final UpdateAdapter<Vaccine> _vaccineUpdateAdapter;

  final DeletionAdapter<Vaccine> _vaccineDeletionAdapter;

  @override
  Future<List<Vaccine>> findAll() async {
    return _queryAdapter.queryList(
        'SELECT * FROM vaccines ORDER BY expirationDate ASC',
        mapper: (Map<String, Object?> row) => Vaccine(
            id: row['id'] as int?,
            name: row['name'] as String,
            dosage: row['dosage'] as String,
            lotNumber: row['lotNumber'] as String,
            expirationDate: row['expirationDate'] as String));
  }

  @override
  Future<void> insertVaccine(Vaccine vaccine) async {
    await _vaccineInsertionAdapter.insert(vaccine, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateVaccine(Vaccine vaccine) async {
    await _vaccineUpdateAdapter.update(vaccine, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteVaccine(Vaccine vaccine) async {
    await _vaccineDeletionAdapter.delete(vaccine);
  }
}

class _$VeterinarianDao extends VeterinarianDao {
  _$VeterinarianDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _veterinarianInsertionAdapter = InsertionAdapter(
            database,
            'veterinarians',
            (Veterinarian item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'address': item.address,
                  'university': item.university
                }),
        _veterinarianUpdateAdapter = UpdateAdapter(
            database,
            'veterinarians',
            ['id'],
            (Veterinarian item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'address': item.address,
                  'university': item.university
                }),
        _veterinarianDeletionAdapter = DeletionAdapter(
            database,
            'veterinarians',
            ['id'],
            (Veterinarian item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'address': item.address,
                  'university': item.university
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Veterinarian> _veterinarianInsertionAdapter;

  final UpdateAdapter<Veterinarian> _veterinarianUpdateAdapter;

  final DeletionAdapter<Veterinarian> _veterinarianDeletionAdapter;

  @override
  Future<List<Veterinarian>> findAll() async {
    return _queryAdapter.queryList(
        'SELECT * FROM veterinarians ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => Veterinarian(
            id: row['id'] as int?,
            name: row['name'] as String,
            birthday: row['birthday'] as String,
            address: row['address'] as String,
            university: row['university'] as String));
  }

  @override
  Future<void> insertVeterinarian(Veterinarian veterinarian) async {
    await _veterinarianInsertionAdapter.insert(
        veterinarian, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateVeterinarian(Veterinarian veterinarian) async {
    await _veterinarianUpdateAdapter.update(
        veterinarian, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteVeterinarian(Veterinarian veterinarian) async {
    await _veterinarianDeletionAdapter.delete(veterinarian);
  }
}
