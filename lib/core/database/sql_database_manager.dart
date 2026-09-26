import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Database? _database;

  // =========================
  // DATABASE GETTER
  // =========================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  // =========================
  // INIT DATABASE
  // =========================

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      'calculation_panel.db',
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE extra_charges (
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
      },
    );
  }

  // ============================================================
  // INSERT
  // ============================================================

  Future<int> insertExtraCharge(
      Map<String, String> formData,
      ) async {
    final db = await database;

    final data = {
      'charge_name': formData['charge_name'],
      'charge_type': formData['charge_type'],
      'charge_nature': formData['charge_nature'],
      'print_name': formData['print_name'],
      'default_value': formData['default_value'],
      'calculation_type': formData['calculation_type'],
      'applied_on': formData['applied_on'],
      'distribution_method': formData['distribution_method'],
      'tax_treatment': formData['tax_treatment'],
      'hsn': formData['hsn'],
      'hsn_tax': formData['hsn_tax'],
      'allow_manual_change':
      formData['allow_manual_change'] == '1' ? 1 : 0,
      'is_active':
      formData['is_active'] == '1' ? 1 : 0,
    };

    return await db.insert(
      'extra_charges',
      data,
    );
  }

  // ============================================================
  // GET ALL
  // ============================================================

  Future<List<Map<String, dynamic>>> getExtraCharges(String search) async {
    final db = await database;

    if (search.trim().isEmpty) {
      return await db.query(
        'extra_charges',
        orderBy: 'id DESC',
      );
    }

    return await db.query(
      'extra_charges',
      where: 'charge_name LIKE ?',
      whereArgs: ['%${search.trim()}%'],
      orderBy: 'id DESC',
    );
  }

  // ============================================================
  // GET BY ID
  // ============================================================

  Future<Map<String, dynamic>?> getExtraChargeById(
      int id,
      ) async {
    final db = await database;

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
  // UPDATE
  // ============================================================

  Future<int> updateExtraCharge(
      int id,
      Map<String, String> formData,
      ) async {
    final db = await database;

    final data = {
      'charge_name': formData['charge_name'],
      'charge_type': formData['charge_type'],
      'charge_nature': formData['charge_nature'],
      'print_name': formData['print_name'],
      'default_value': formData['default_value'],
      'calculation_type': formData['calculation_type'],
      'applied_on': formData['applied_on'],
      'distribution_method': formData['distribution_method'],
      'tax_treatment': formData['tax_treatment'],
      'hsn': formData['hsn'],
      'hsn_tax': formData['hsn_tax'],
      'allow_manual_change':
      formData['allow_manual_change'] == '1' ? 1 : 0,
      'is_active':
      formData['is_active'] == '1' ? 1 : 0,
    };

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

  Future<int> deleteExtraCharge(
      int id,
      ) async {
    final db = await database;

    return await db.delete(
      'extra_charges',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}