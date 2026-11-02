
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  AppDatabase._internal();

  Database? _database;

  // ============================================================
  // DATABASE GETTER
  // ============================================================

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  // ============================================================
  // INITIALIZE DATABASE
  // ============================================================

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calculation_panel.db');

    return openDatabase(
      path,
      version: 1,
    );
  }

  // ============================================================
  // DELETE ALL SAVED SQLITE DATA
  // ============================================================

  Future<void> deleteAllData() async {
    final db = await database;

    await db.transaction((txn) async {
      final tables = await txn.rawQuery('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
          AND name NOT LIKE 'sqlite_%'
          AND name != 'android_metadata'
        ORDER BY name
      ''');

      for (final table in tables) {
        await txn.delete(table['name'] as String);
      }
    });
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
