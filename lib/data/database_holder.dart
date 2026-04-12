import 'app_database.dart';

/// Opens the Floor database once and shares it app-wide (SQLite.txt: open in `initState` / startup).
///
/// Call [init] from `main()` after [WidgetsFlutterBinding.ensureInitialized].
class DatabaseHolder {
  DatabaseHolder._();

  static AppDatabase? _db;

  /// Singleton [AppDatabase] — throws if [init] was not awaited successfully.
  static AppDatabase get instance {
    final db = _db;
    if (db == null) {
      throw StateError('DatabaseHolder.init() must run before accessing instance.');
    }
    return db;
  }

  /// Builds `vet_clinic.db` on device storage (course: change the filename string if needed).
  static Future<void> init() async {
    _db ??= await $FloorAppDatabase.databaseBuilder('vet_clinic.db').build();
  }
}
