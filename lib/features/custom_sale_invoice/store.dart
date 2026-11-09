import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'models.dart';

/// Holds all app data and saves it to a JSON file on this computer.
/// On Windows the file is  Documents\BillingApp\billing_data.json
class AppStore extends ChangeNotifier {
  late File _file;

  String get dataPath => _file.path;
  String get _sep => Platform.pathSeparator;

  List<Invoice> invoices = [];
  List<Customer> customers = [];
  List<Product> products = [];
  Settings settings = Settings();

  Future<void> init() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}${Platform.pathSeparator}BillingApp');
    if (!await dir.exists()) await dir.create(recursive: true);
    _file = File('${dir.path}${Platform.pathSeparator}billing_data.json');
    if (await _file.exists()) {
      try {
        final data = Map<String, dynamic>.from(jsonDecode(await _file.readAsString()) as Map);
        _loadFrom(data);
      } catch (_) {
        // Keep the unreadable file as a copy so nothing is lost, then start clean.
        await _file.copy('${_file.path}.broken-${DateTime.now().millisecondsSinceEpoch}');
      }
    }
  }

  void _loadFrom(Map<String, dynamic> data) {
    Map<String, dynamic> m(dynamic e) => Map<String, dynamic>.from(e as Map);
    invoices = (data['invoices'] as List? ?? []).map((e) => Invoice.fromJson(m(e))).toList();
    customers = (data['customers'] as List? ?? []).map((e) => Customer.fromJson(m(e))).toList();
    products = (data['products'] as List? ?? []).map((e) => Product.fromJson(m(e))).toList();
    final s = data['settings'];
    settings = (s is Map && s.isNotEmpty) ? Settings.fromJson(m(s)) : Settings();
  }

  Map<String, dynamic> _toMap() => {
        'invoices': invoices.map((e) => e.toJson()).toList(),
        'customers': customers.map((e) => e.toJson()).toList(),
        'products': products.map((e) => e.toJson()).toList(),
        'settings': settings.toJson(),
      };

  Future<void> _save() async {
    // Write to a temp file first, then replace, so a crash never leaves half a file.
    final tmp = File('${_file.path}.tmp');
    await tmp.writeAsString(const JsonEncoder.withIndent('  ').convert(_toMap()), flush: true);
    await tmp.rename(_file.path);
    notifyListeners();
  }

  // ---- invoices ----
  String nextInvoiceNumber() =>
      '${settings.prefix}${settings.nextNumber.toString().padLeft(4, '0')}';

  Invoice? invoiceById(String id) {
    for (final i in invoices) {
      if (i.id == id) return i;
    }
    return null;
  }

  Future<void> saveInvoice(Invoice inv) async {
    final idx = invoices.indexWhere((e) => e.id == inv.id);
    if (idx >= 0) {
      invoices[idx] = inv;
    } else {
      invoices.insert(0, inv);
      if (inv.number == nextInvoiceNumber()) settings.nextNumber += 1;
    }
    await _save();
  }

  Future<void> deleteInvoice(String id) async {
    invoices.removeWhere((e) => e.id == id);
    await _save();
  }

  Future<void> addPayment(String invoiceId, Payment p) async {
    invoiceById(invoiceId)?.payments.add(p);
    await _save();
  }

  Future<void> deletePayment(String invoiceId, String paymentId) async {
    invoiceById(invoiceId)?.payments.removeWhere((p) => p.id == paymentId);
    await _save();
  }

  // ---- customers ----
  Future<void> saveCustomer(Customer c) async {
    final idx = customers.indexWhere((e) => e.id == c.id);
    if (idx >= 0) {
      customers[idx] = c;
    } else {
      customers.add(c);
    }
    customers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    await _save();
  }

  Future<void> deleteCustomer(String id) async {
    customers.removeWhere((e) => e.id == id);
    await _save();
  }

  // ---- products ----
  Future<void> saveProduct(Product p) async {
    final idx = products.indexWhere((e) => e.id == p.id);
    if (idx >= 0) {
      products[idx] = p;
    } else {
      products.add(p);
    }
    products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    await _save();
  }

  Future<void> deleteProduct(String id) async {
    products.removeWhere((e) => e.id == id);
    await _save();
  }

  // ---- settings, backup, export ----
  Future<void> saveSettings(Settings s) async {
    settings = s;
    await _save();
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert(_toMap());

  /// Replaces all data with the backup. Throws if the text is not a valid backup.
  Future<void> importJson(String text) async {
    final data = Map<String, dynamic>.from(jsonDecode(text) as Map);
    _loadFrom(data);
    await _save();
  }

  String _csv(Object v) {
    final s = v.toString();
    return RegExp(r'[",\n]').hasMatch(s) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  /// Writes the given invoices to a CSV file (opens in Excel) and returns its path.
  Future<String> exportCsv(List<Invoice> list) async {
    final dir = Directory('${_file.parent.path}${_sep}exports');
    if (!await dir.exists()) await dir.create(recursive: true);
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final f = File('${dir.path}${_sep}invoices_$stamp.csv');
    String n(double v) => v.toStringAsFixed(2);
    final b = StringBuffer(
        'Invoice No,Date,Customer,GSTIN,State,Taxable Value,CGST,SGST,IGST,Round Off,Total,Received,Balance,Status\n');
    for (final i in list) {
      b.writeln([
        i.number,
        DateFormat('yyyy-MM-dd').format(i.date),
        i.customerName,
        i.customerGstin,
        i.customerState,
        n(i.taxableValue),
        n(i.cgst),
        n(i.sgst),
        n(i.igst),
        n(i.roundOffAmount),
        n(i.total),
        n(i.paid),
        n(i.balance),
        i.status,
      ].map(_csv).join(','));
    }
    await f.writeAsString('﻿$b'); // BOM so Excel reads it as UTF-8
    return f.path;
  }
}
