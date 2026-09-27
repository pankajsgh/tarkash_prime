import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class ExtraChargeDatabase {
  static final ExtraChargeDatabase instance =
  ExtraChargeDatabase._internal();

  ExtraChargeDatabase._internal();

  // ============================================================
  // DATABASE
  // ============================================================

  Future<Database> get database async {
    return await AppDatabase.instance.database;
  }

  // ============================================================
  // CREATE TABLE
  // ============================================================

  Future<void> createTable() async {
    final db = await database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS extra_charges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        charge_name TEXT NOT NULL,
        charge_type TEXT NOT NULL,

        charge_nature TEXT,
        print_name TEXT,

        default_value TEXT,
        calculation_type TEXT,

        applied_on TEXT,
        distribution_method TEXT,

        tax_treatment TEXT,

        hsn TEXT,
        hsn_tax TEXT,

        allow_manual_change INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1
      )
    ''');
  }

  // ============================================================
  // INSERT
  // ============================================================

  Future<int> insert(
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    await createTable();

    return await db.insert(
      'extra_charges',
      data,
    );
  }

  // ============================================================
  // GET ALL
  // ============================================================

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;

    await createTable();

    return await db.query(
      'extra_charges',
      orderBy: 'id DESC',
    );
  }

  // ============================================================
  // GET BY ID
  // ============================================================

  Future<Map<String, dynamic>?> getById(
      int id,
      ) async {
    final db = await database;

    await createTable();

    final result = await db.query(
      'extra_charges',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<List<Map<String, dynamic>>> search(
      String value,
      ) async {
    final db = await database;

    await createTable();

    if (value.trim().isEmpty) {
      return getAll();
    }

    return await db.query(
      'extra_charges',
      where: 'charge_name LIKE ?',
      whereArgs: [
        '%${value.trim()}%',
      ],
      orderBy: 'id DESC',
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<int> update(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    await createTable();

    return await db.update(
      'extra_charges',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<int> delete(
      int id,
      ) async {
    final db = await database;

    await createTable();

    return await db.delete(
      'extra_charges',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}