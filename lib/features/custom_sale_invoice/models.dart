import 'dart:math' as math;

class Customer {
  final String id;
  String name, phone, email, address, gstin, state;

  Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.gstin = '',
    this.state = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'gstin': gstin,
        'state': state,
      };

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String? ?? '',
        address: j['address'] as String? ?? '',
        gstin: j['gstin'] as String? ?? '',
        state: j['state'] as String? ?? '',
      );
}

class Product {
  final String id;
  String name, hsn, unit;
  double price, taxPercent;

  Product({
    required this.id,
    required this.name,
    this.hsn = '',
    this.unit = 'pcs',
    this.price = 0,
    this.taxPercent = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hsn': hsn,
        'unit': unit,
        'price': price,
        'taxPercent': taxPercent,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        hsn: j['hsn'] as String? ?? '',
        unit: j['unit'] as String? ?? 'pcs',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        taxPercent: (j['taxPercent'] as num?)?.toDouble() ?? 0,
      );
}

class LineItem {
  String name, hsn, unit;
  double qty, price, discountPercent, taxPercent;

  LineItem({
    this.name = '',
    this.hsn = '',
    this.unit = 'pcs',
    this.qty = 1,
    this.price = 0,
    this.discountPercent = 0,
    this.taxPercent = 0,
  });

  double get gross => qty * price;
  double get discount => gross * discountPercent / 100;
  double get taxable => gross - discount;
  double get total => taxable + taxable * taxPercent / 100;

  Map<String, dynamic> toJson() => {
        'name': name,
        'hsn': hsn,
        'unit': unit,
        'qty': qty,
        'price': price,
        'discountPercent': discountPercent,
        'taxPercent': taxPercent,
      };

  factory LineItem.fromJson(Map<String, dynamic> j) => LineItem(
        name: j['name'] as String? ?? '',
        hsn: j['hsn'] as String? ?? '',
        unit: j['unit'] as String? ?? 'pcs',
        qty: (j['qty'] as num?)?.toDouble() ?? 1,
        price: (j['price'] as num?)?.toDouble() ?? 0,
        discountPercent: (j['discountPercent'] as num?)?.toDouble() ?? 0,
        taxPercent: (j['taxPercent'] as num?)?.toDouble() ?? 0,
      );
}

class Payment {
  final String id;
  DateTime date;
  double amount;
  String mode, note;

  Payment({
    required this.id,
    required this.date,
    required this.amount,
    this.mode = 'Cash',
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'mode': mode,
        'note': note,
      };

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        mode: j['mode'] as String? ?? 'Cash',
        note: j['note'] as String? ?? '',
      );
}

/// One row of the tax summary (grouped by HSN and tax rate).
class TaxRow {
  final String hsn;
  final double rate;
  double taxable = 0;
  double tax = 0;
  TaxRow(this.hsn, this.rate);
}

class Invoice {
  final String id;
  String number;
  DateTime date, dueDate;
  String customerName, customerPhone, customerAddress, customerGstin, customerState, notes;
  List<LineItem> items;
  bool discountIsPercent; // bill-level discount type
  double discountValue; // bill-level discount value
  bool interState; // true = IGST, false = CGST + SGST
  bool roundOff;
  List<Payment> payments;

  Invoice({
    required this.id,
    required this.number,
    required this.date,
    required this.dueDate,
    this.customerName = '',
    this.customerPhone = '',
    this.customerAddress = '',
    this.customerGstin = '',
    this.customerState = '',
    this.notes = '',
    List<LineItem>? items,
    this.discountIsPercent = true,
    this.discountValue = 0,
    this.interState = false,
    this.roundOff = true,
    List<Payment>? payments,
  })  : items = items ?? [],
        payments = payments ?? [];

  // ---- amounts ----
  double get grossTotal => items.fold(0.0, (s, i) => s + i.gross);
  double get itemDiscounts => items.fold(0.0, (s, i) => s + i.discount);
  double get itemsTaxable => grossTotal - itemDiscounts;

  double get billDiscount {
    final raw = discountIsPercent ? itemsTaxable * discountValue / 100 : discountValue;
    return math.min(math.max(0.0, raw), itemsTaxable);
  }

  double get taxableValue => itemsTaxable - billDiscount;

  double get _factor => itemsTaxable <= 0 ? 0.0 : taxableValue / itemsTaxable;

  /// Taxable value of a line after its share of the bill discount.
  double lineTaxable(LineItem i) => i.taxable * _factor;
  double lineTax(LineItem i) => lineTaxable(i) * i.taxPercent / 100;

  double get totalTax => items.fold(0.0, (s, i) => s + lineTax(i));
  double get cgst => interState ? 0.0 : totalTax / 2;
  double get sgst => interState ? 0.0 : totalTax / 2;
  double get igst => interState ? totalTax : 0.0;

  double get rawTotal => taxableValue + totalTax;
  double get total => roundOff ? rawTotal.roundToDouble() : rawTotal;
  double get roundOffAmount => total - rawTotal;

  double get paid => payments.fold(0.0, (s, p) => s + p.amount);
  double get balance => math.max(0.0, total - paid);

  String get status {
    if (total > 0 && balance < 0.005) return 'Paid';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (dueDate.isBefore(today)) return 'Overdue';
    if (paid > 0) return 'Partial';
    return 'Unpaid';
  }

  List<TaxRow> get taxRows {
    final m = <String, TaxRow>{};
    for (final i in items) {
      final r = m.putIfAbsent('${i.hsn}|${i.taxPercent}', () => TaxRow(i.hsn, i.taxPercent));
      r.taxable += lineTaxable(i);
      r.tax += lineTax(i);
    }
    return m.values.toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'date': date.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'customerGstin': customerGstin,
        'customerState': customerState,
        'notes': notes,
        'items': items.map((e) => e.toJson()).toList(),
        'discountIsPercent': discountIsPercent,
        'discountValue': discountValue,
        'interState': interState,
        'roundOff': roundOff,
        'payments': payments.map((e) => e.toJson()).toList(),
      };

  factory Invoice.fromJson(Map<String, dynamic> j) {
    final payments = ((j['payments'] as List?) ?? [])
        .map((e) => Payment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    // Older files stored a single "paid" number instead of a payment list.
    final oldPaid = (j['paid'] as num?)?.toDouble() ?? 0;
    if (payments.isEmpty && oldPaid > 0) {
      payments.add(Payment(
        id: '${j['id']}-p0',
        date: DateTime.parse(j['date'] as String),
        amount: oldPaid,
      ));
    }
    return Invoice(
      id: j['id'] as String,
      number: j['number'] as String? ?? '',
      date: DateTime.parse(j['date'] as String),
      dueDate: DateTime.parse(j['dueDate'] as String),
      customerName: j['customerName'] as String? ?? '',
      customerPhone: j['customerPhone'] as String? ?? '',
      customerAddress: j['customerAddress'] as String? ?? '',
      customerGstin: j['customerGstin'] as String? ?? '',
      customerState: j['customerState'] as String? ?? '',
      notes: j['notes'] as String? ?? '',
      items: ((j['items'] as List?) ?? [])
          .map((e) => LineItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      discountIsPercent: j['discountIsPercent'] as bool? ?? false,
      discountValue: (j['discountValue'] as num?)?.toDouble() ??
          (j['discount'] as num?)?.toDouble() ??
          0,
      interState: j['interState'] as bool? ?? false,
      roundOff: j['roundOff'] as bool? ?? false,
      payments: payments,
    );
  }
}

class Settings {
  String businessName, address, phone, email, gstin, state;
  String currency, prefix, invoiceTitle, bankDetails, upi, terms;
  int nextNumber;
  double defaultTax;
  bool roundOff;

  Settings({
    this.businessName = 'My Business',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.gstin = '',
    this.state = '',
    this.currency = '₹',
    this.prefix = 'INV-',
    this.invoiceTitle = 'TAX INVOICE',
    this.bankDetails = '',
    this.upi = '',
    this.terms = 'Goods once sold will not be taken back. Subject to local jurisdiction.',
    this.nextNumber = 1,
    this.defaultTax = 18,
    this.roundOff = true,
  });

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'address': address,
        'phone': phone,
        'email': email,
        'gstin': gstin,
        'state': state,
        'currency': currency,
        'prefix': prefix,
        'invoiceTitle': invoiceTitle,
        'bankDetails': bankDetails,
        'upi': upi,
        'terms': terms,
        'nextNumber': nextNumber,
        'defaultTax': defaultTax,
        'roundOff': roundOff,
      };

  factory Settings.fromJson(Map<String, dynamic> j) {
    final d = Settings();
    return Settings(
      businessName: j['businessName'] as String? ?? d.businessName,
      address: j['address'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      email: j['email'] as String? ?? '',
      gstin: j['gstin'] as String? ?? '',
      state: j['state'] as String? ?? '',
      currency: j['currency'] as String? ?? d.currency,
      prefix: j['prefix'] as String? ?? d.prefix,
      invoiceTitle: j['invoiceTitle'] as String? ?? d.invoiceTitle,
      bankDetails: j['bankDetails'] as String? ?? '',
      upi: j['upi'] as String? ?? '',
      terms: j['terms'] as String? ?? d.terms,
      nextNumber: (j['nextNumber'] as num?)?.toInt() ?? 1,
      defaultTax: (j['defaultTax'] as num?)?.toDouble() ?? 18,
      roundOff: j['roundOff'] as bool? ?? true,
    );
  }
}
