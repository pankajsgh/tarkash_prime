import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models.dart';
import 'theme.dart';

const kStates = <String>[
  'Andaman and Nicobar Islands',
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chandigarh',
  'Chhattisgarh',
  'Dadra and Nagar Haveli and Daman and Diu',
  'Delhi',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jammu and Kashmir',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Ladakh',
  'Lakshadweep',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Puducherry',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
];

const kPayModes = <String>['Cash', 'UPI', 'Card', 'Bank transfer', 'Cheque', 'Other'];
const kUnits = <String>['pcs', 'nos', 'kg', 'g', 'ltr', 'ml', 'mtr', 'box', 'set', 'hr', 'day', 'service'];

String money(double v, String symbol) =>
    NumberFormat.currency(locale: 'en_IN', symbol: symbol, decimalDigits: 2).format(v);

String compactMoney(double v, String sym) {
  final a = v.abs();
  String t;
  if (a >= 10000000) {
    t = '${(v / 10000000).toStringAsFixed(2)} Cr';
  } else if (a >= 100000) {
    t = '${(v / 100000).toStringAsFixed(2)} L';
  } else if (a >= 1000) {
    t = '${(v / 1000).toStringAsFixed(1)}K';
  } else {
    t = v.toStringAsFixed(0);
  }
  return '$sym$t';
}

String fmtDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

String newId() => DateTime.now().microsecondsSinceEpoch.toString();

String qtyText(double q) => q == q.roundToDouble() ? q.toInt().toString() : q.toString();

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

Color statusColor(String s) {
  switch (s) {
    case 'Paid':
      return AppColors.good;
    case 'Partial':
      return AppColors.warn;
    case 'Overdue':
      return AppColors.bad;
    default:
      return AppColors.muted;
  }
}

Widget statusPill(String s) {
  final c = statusColor(s);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: c.withAlpha(28), borderRadius: BorderRadius.circular(20)),
    child: Text(s, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

void snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, width: 460));
}

Future<bool> confirm(BuildContext context, String title, String body, {String label = 'Delete'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(label)),
      ],
    ),
  );
  return r ?? false;
}

// ---- amount in words (Indian system: lakh, crore) ----
const _ones = [
  '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
  'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen',
];
const _tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

String _two(int n) => n < 20 ? _ones[n] : _tens[n ~/ 10] + (n % 10 > 0 ? ' ${_ones[n % 10]}' : '');

String _words(int value) {
  if (value == 0) return 'Zero';
  var n = value;
  final parts = <String>[];
  final crore = n ~/ 10000000;
  n %= 10000000;
  final lakh = n ~/ 100000;
  n %= 100000;
  final thousand = n ~/ 1000;
  n %= 1000;
  final hundred = n ~/ 100;
  n %= 100;
  if (crore > 0) parts.add('${_words(crore)} Crore');
  if (lakh > 0) parts.add('${_two(lakh)} Lakh');
  if (thousand > 0) parts.add('${_two(thousand)} Thousand');
  if (hundred > 0) parts.add('${_ones[hundred]} Hundred');
  if (n > 0) parts.add(_two(n));
  return parts.join(' ');
}

String amountInWords(double amount, String symbol) {
  final total = (amount * 100).round();
  final main = total ~/ 100;
  final sub = total % 100;
  final isRupee = symbol.trim() == '₹';
  var s = '${isRupee ? 'Rupees' : 'Amount'} ${_words(main)}';
  if (sub > 0) s += ' and ${_words(sub)} ${isRupee ? 'Paise' : 'cents'}';
  return '$s Only';
}

/// Plain text version of an invoice, for copying into WhatsApp or email.
String invoiceText(Invoice i, Settings s) {
  final sym = s.currency;
  final b = StringBuffer();
  b.writeln(s.businessName);
  if (s.address.isNotEmpty) b.writeln(s.address);
  if (s.phone.isNotEmpty) b.writeln('Phone: ${s.phone}');
  if (s.gstin.isNotEmpty) b.writeln('GSTIN: ${s.gstin}');
  b.writeln('');
  b.writeln('${s.invoiceTitle}  ${i.number}');
  b.writeln('Date: ${fmtDate(i.date)}   Due: ${fmtDate(i.dueDate)}');
  b.writeln('');
  b.writeln('Bill to: ${i.customerName}');
  if (i.customerAddress.isNotEmpty) b.writeln(i.customerAddress);
  if (i.customerGstin.isNotEmpty) b.writeln('GSTIN: ${i.customerGstin}');
  b.writeln('');
  var n = 1;
  for (final it in i.items) {
    b.writeln('$n. ${it.name}${it.hsn.isNotEmpty ? ' (HSN ${it.hsn})' : ''}  '
        '${qtyText(it.qty)} x ${money(it.price, sym)}'
        '${it.discountPercent > 0 ? '  -${qtyText(it.discountPercent)}%' : ''}'
        '  = ${money(it.total, sym)}');
    n++;
  }
  b.writeln('');
  b.writeln('Taxable value: ${money(i.taxableValue, sym)}');
  if (i.interState) {
    b.writeln('IGST: ${money(i.igst, sym)}');
  } else {
    b.writeln('CGST: ${money(i.cgst, sym)}');
    b.writeln('SGST: ${money(i.sgst, sym)}');
  }
  b.writeln('Total: ${money(i.total, sym)}');
  b.writeln('Received: ${money(i.paid, sym)}');
  b.writeln('Balance due: ${money(i.balance, sym)}');
  if (s.upi.isNotEmpty) b.writeln('Pay by UPI: ${s.upi}');
  return b.toString();
}
