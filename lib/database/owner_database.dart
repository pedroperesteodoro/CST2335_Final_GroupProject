import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/pet_owner.dart';

/// Singleton SQLite database helper for [PetOwner] CRUD operations.
class OwnerDatabase {
  /// The single shared instance of this database helper.
  static final OwnerDatabase instance = OwnerDatabase._init();
  static Database? _database;

  OwnerDatabase._init();

  /// Initialize FFI for desktop platforms
  static void _initFFI() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Returns the open database, initializing it on first call.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _initFFI(); // ← Initialize FFI before opening database
    _database = await _initDB('pet_owners.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pet_owners (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName       TEXT NOT NULL,
        lastName        TEXT NOT NULL,
        address         TEXT NOT NULL,
        dateOfBirth     TEXT NOT NULL,
        insuranceNumber TEXT NOT NULL DEFAULT ""
      )
    ''');
  }

  /// Inserts [owner] into the database and returns the new row id.
  Future<int> insertOwner(PetOwner owner) async {
    final db = await database;
    return await db.insert(
      'pet_owners',
      owner.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates [owner] in the database. Returns the number of rows changed.
  Future<int> updateOwner(PetOwner owner) async {
    final db = await database;
    return await db.update(
      'pet_owners',
      owner.toMap(),
      where: 'id = ?',
      whereArgs: [owner.id],
    );
  }

  /// Deletes the owner with [id]. Returns the number of rows deleted.
  Future<int> deleteOwner(int id) async {
    final db = await database;
    return await db.delete('pet_owners', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns all owners ordered alphabetically by last name.
  Future<List<PetOwner>> getAllOwners() async {
    final db = await database;
    final rows = await db.query(
      'pet_owners',
      orderBy: 'lastName ASC, firstName ASC',
    );
    return rows.map((r) => PetOwner.fromMap(r)).toList();
  }

  /// Returns owners whose first or last name contains [query].
  Future<List<PetOwner>> searchOwners(String query) async {
    final db = await database;
    final rows = await db.query(
      'pet_owners',
      where: 'firstName LIKE ? OR lastName LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'lastName ASC',
    );
    return rows.map((r) => PetOwner.fromMap(r)).toList();
  }
}