import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class PurchaseDatabase {
  static final PurchaseDatabase instance =
  PurchaseDatabase._internal();

  PurchaseDatabase._internal();

  // ============================================================
  // DATABASE
  // ============================================================

  Future<Database> get database async {
    return await AppDatabase.instance.database;
  }

  // ============================================================
  // CREATE PURCHASE CHALLAN TABLE
  // ============================================================

  Future<void> createPurchaseChallanTable() async {
    final db = await database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS purchase_challans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        supplier_id TEXT,
        bill_date TEXT,
        search TEXT,
        limit_value TEXT,

        select_supplier TEXT,
        gst_no TEXT,
        selected_store TEXT,

        challan_no TEXT,

        lr_no TEXT,
        lr_date TEXT,

        remark TEXT,

        selected_data TEXT,
        selected_transport TEXT,
        selected_agent TEXT,

        additional_discount_total TEXT,
        additional_charge_value TEXT,

        final_discount TEXT,
        value_of_good TEXT,
        taxable_amount TEXT,

        igst TEXT,
        sgst TEXT,
        cgst TEXT,

        grand_total TEXT,

        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  // ============================================================
  // CREATE PURCHASE ITEMS TABLE
  // ============================================================

  Future<void> createPurchaseItemsTable() async {
    final db = await database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS purchase_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        purchase_id TEXT,

        item_id TEXT,
        product_id TEXT,

        amount TEXT,
        item_qty TEXT,

        size TEXT,
        color TEXT,

        hsn TEXT,

        discount_per TEXT,
        extra_discount TEXT,
        extra_charge TEXT,

        item_final_price TEXT,

        gst TEXT,

        created_at TEXT
      )
    ''');
  }

  // ============================================================
  // CREATE PURCHASE EXTRA CHARGES TABLE
  // ============================================================

  Future<void> createPurchaseExtraChargesTable() async {
    final db = await database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS purchase_extra_charges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        purchase_id TEXT,

        charge_id TEXT,
        name TEXT,

        amount TEXT,
        tax_percent TEXT,

        tax_type TEXT,

        is_discount TEXT,
        is_tax_applicable TEXT,

        created_at TEXT
      )
    ''');
  }

  // ============================================================
  // CREATE ALL TABLES
  // ============================================================

  Future<void> createTables() async {
    await createPurchaseChallanTable();
    await createPurchaseItemsTable();
    await createPurchaseExtraChargesTable();
  }

  // ============================================================
  // SAVE COMPLETE PURCHASE
  // ============================================================

  Future<int> saveCompletePurchase(
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    await createTables();

    return await db.transaction<int>((txn) async {
      final now = DateTime.now().toIso8601String();

      final challanNo =
      '${data['challanNo'] ?? ''}'.trim();

      // ========================================================
      // CHECK DUPLICATE CHALLAN
      // ========================================================

      if (challanNo.isNotEmpty) {
        final existing = await txn.query(
          'purchase_challans',
          columns: ['id'],
          where: 'challan_no = ?',
          whereArgs: [challanNo],
          limit: 1,
        );

        if (existing.isNotEmpty) {
          print(
            'Challan already exists: $challanNo',
          );

          return 0;
        }
      }

      // ========================================================
      // DECODE ITEMS
      // ========================================================

      final List<dynamic> items =
      jsonDecode(data['items'] ?? '[]');

      // ========================================================
      // DECODE EXTRA CHARGES
      // ========================================================

      final List<dynamic> extraCharges =
      jsonDecode(data['extraCharge'] ?? '[]');

      // ========================================================
      // PURCHASE
      // ========================================================

      final purchaseId = await txn.insert(
        'purchase_challans',
        {
          'supplier_id':
          '${data['selectSupplier'] ?? ''}',

          'bill_date':
          '${data['selectedData'] ?? ''}',

          'search':
          '${data['search'] ?? ''}',

          'limit_value':
          '${data['limit'] ?? ''}',

          'select_supplier':
          '${data['selectSupplier'] ?? ''}',

          'gst_no':
          '${data['gstNo'] ?? ''}',

          'selected_store':
          '${data['selectedStore'] ?? ''}',

          'challan_no':
          challanNo,

          'lr_no':
          '${data['lrNo'] ?? ''}',

          'lr_date':
          '${data['lrDate'] ?? ''}',

          'remark':
          '${data['remark'] ?? ''}',

          'selected_data':
          '${data['selectedData'] ?? ''}',

          'selected_transport':
          '${data['selectedTransport'] ?? ''}',

          'selected_agent':
          '${data['selectedAgent'] ?? ''}',

          'additional_discount_total':
          '${data['additionalDiscountTotal'] ?? ''}',

          'additional_charge_value':
          '${data['additionalChargeValue'] ?? ''}',

          'final_discount':
          '${data['finalDiscount'] ?? ''}',

          'value_of_good':
          '${data['valueOfGood'] ?? ''}',

          'taxable_amount':
          '${data['taxableAmount'] ?? ''}',

          'igst':
          '${data['igst'] ?? ''}',

          'sgst':
          '${data['sgst'] ?? ''}',

          'cgst':
          '${data['cgst'] ?? ''}',

          'grand_total':
          '${data['grandTotal'] ?? ''}',

          'created_at': now,
          'updated_at': now,
        },
      );

      // ========================================================
      // ITEMS
      // ========================================================

      for (final item in items) {
        await txn.insert(
          'purchase_items',
          {
            'purchase_id': purchaseId.toString(),
            'item_id': '${item['id'] ?? ''}',
            'product_id': '${item['productId'] ?? ''}',
            'amount': '${item['amount'] ?? ''}',
            'item_qty': '${item['item_qty'] ?? ''}',
            'size': '${item['size'] ?? ''}',
            'color': '${item['color'] ?? ''}',
            'hsn': '${item['hsn'] ?? ''}',
            'discount_per': '${item['discount_per'] ?? ''}',
            'extra_discount': '${item['extra_discount'] ?? ''}',
            'extra_charge': '${item['extra_charge'] ?? ''}',
            'item_final_price':
            '${item['itemFinalPrice'] ?? ''}',
            'gst': '${item['gst'] ?? ''}',
            'created_at': now,
          },
        );
      }

      // ========================================================
      // EXTRA CHARGES
      // ========================================================

      for (final charge in extraCharges) {
        await txn.insert(
          'purchase_extra_charges',
          {
            'purchase_id': purchaseId.toString(),
            'charge_id': '${charge['id'] ?? ''}',
            'name': '${charge['name'] ?? ''}',
            'amount': '${charge['amount'] ?? ''}',
            'tax_percent': '${charge['taxPercent'] ?? ''}',
            'tax_type': '${charge['taxType'] ?? ''}',
            'is_discount': '${charge['isDiscount'] ?? ''}',
            'is_tax_applicable':
            '${charge['isTaxApplicable'] ?? ''}',
            'created_at': now,
          },
        );
      }

      return purchaseId;
    });
  }


  // ============================================================
// GET ALL CHALLANS
// ============================================================

  Future<List<Map<String, dynamic>>> getAllChallans() async {
    final db = await database;

    await createTables();

    final result = await db.rawQuery('''
    SELECT
      p.id,
      p.select_supplier AS supplier_id,
      p.gst_no,

      p.selected_store AS store_id,
      '' AS store_name,

      p.challan_no,
      p.selected_data AS challan_date,

      p.lr_no,
      p.lr_date,

      p.selected_transport AS transport_id,
      '' AS transport_name,

      p.selected_agent AS agent_id,
      '' AS agent_name,

      p.value_of_good,
      p.additional_discount_total,
      p.additional_charge_value,
      p.final_discount,
      p.taxable_amount,

      p.sgst,
      p.cgst,
      p.igst,

      p.grand_total,

      p.remark,
      p.created_at,
      p.updated_at,

      (
        SELECT COUNT(*)
        FROM purchase_items i
        WHERE i.purchase_id = p.id
      ) AS item_count

    FROM purchase_challans p

    ORDER BY p.id DESC
  ''');

    return result;
  }
}