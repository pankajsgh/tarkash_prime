import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'models.dart';
import 'utils.dart';

// The built-in PDF fonts have no rupee glyph, so the PDF writes "Rs." instead.
String _sym(String s) => s.trim() == '₹' ? 'Rs. ' : s;
String _m(double v, String symbol) => '${_sym(symbol)}${money(v, '').trim()}';
String _n(double v) => money(v, '').trim();

Future<Uint8List> buildInvoicePdf(Invoice inv, Settings s) async {
  final doc = pw.Document();
  final cur = s.currency;
  final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold);
  const small = pw.TextStyle(fontSize: 9, color: PdfColors.grey700);
  const base = pw.TextStyle(fontSize: 9.5);

  pw.Widget cell(String t, {bool right = false, bool head = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 5),
        child: pw.Text(
          t,
          textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
          style: head ? pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold) : base,
        ),
      );

  pw.Widget totalRow(String l, String v, {bool strong = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(l, style: strong ? pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold) : base),
            pw.Text(v, style: strong ? pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold) : base),
          ],
        ),
      );

  const border = pw.TableBorder(
    top: pw.BorderSide(color: PdfColors.grey600),
    bottom: pw.BorderSide(color: PdfColors.grey600),
    horizontalInside: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
  );
  const headFill = pw.BoxDecoration(color: PdfColors.grey200);

  // Tax summary by HSN and rate.
  final inter = inv.interState;
  final taxHead = inter
      ? ['HSN/SAC', 'Taxable', 'IGST %', 'IGST', 'Total tax']
      : ['HSN/SAC', 'Taxable', 'CGST %', 'CGST', 'SGST %', 'SGST', 'Total tax'];
  final taxRows = <List<String>>[
    for (final r in inv.taxRows)
      inter
          ? [r.hsn.isEmpty ? '-' : r.hsn, _n(r.taxable), qtyText(r.rate), _n(r.tax), _n(r.tax)]
          : [
              r.hsn.isEmpty ? '-' : r.hsn,
              _n(r.taxable),
              qtyText(r.rate / 2),
              _n(r.tax / 2),
              qtyText(r.rate / 2),
              _n(r.tax / 2),
              _n(r.tax),
            ],
  ];

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(s.businessName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  if (s.address.isNotEmpty) pw.Text(s.address, style: base),
                  if (s.phone.isNotEmpty) pw.Text('Phone: ${s.phone}', style: base),
                  if (s.email.isNotEmpty) pw.Text('Email: ${s.email}', style: base),
                  if (s.gstin.isNotEmpty) pw.Text('GSTIN: ${s.gstin}', style: bold),
                  if (s.state.isNotEmpty) pw.Text('State: ${s.state}', style: base),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(s.invoiceTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Invoice no: ${inv.number}', style: bold),
                pw.Text('Date: ${fmtDate(inv.date)}', style: base),
                pw.Text('Due date: ${fmtDate(inv.dueDate)}', style: base),
                pw.Text('Status: ${inv.status}', style: base),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('BILL TO', style: small),
              pw.Text(inv.customerName, style: bold),
              if (inv.customerAddress.isNotEmpty) pw.Text(inv.customerAddress, style: base),
              if (inv.customerPhone.isNotEmpty) pw.Text('Phone: ${inv.customerPhone}', style: base),
              if (inv.customerGstin.isNotEmpty) pw.Text('GSTIN: ${inv.customerGstin}', style: base),
              if (inv.customerState.isNotEmpty) pw.Text('Place of supply: ${inv.customerState}', style: base),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: border,
          columnWidths: {
            0: const pw.FixedColumnWidth(22),
            1: const pw.FlexColumnWidth(4),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1.4),
            5: const pw.FlexColumnWidth(0.9),
            6: const pw.FlexColumnWidth(0.9),
            7: const pw.FlexColumnWidth(1.6),
          },
          children: [
            pw.TableRow(decoration: headFill, children: [
              cell('#', head: true),
              cell('Description', head: true),
              cell('HSN/SAC', head: true),
              cell('Qty', right: true, head: true),
              cell('Rate', right: true, head: true),
              cell('Disc %', right: true, head: true),
              cell('Tax %', right: true, head: true),
              cell('Taxable', right: true, head: true),
            ]),
            for (var i = 0; i < inv.items.length; i++)
              pw.TableRow(children: [
                cell('${i + 1}'),
                cell(inv.items[i].name),
                cell(inv.items[i].hsn),
                cell('${qtyText(inv.items[i].qty)} ${inv.items[i].unit}', right: true),
                cell(_n(inv.items[i].price), right: true),
                cell(inv.items[i].discountPercent > 0 ? qtyText(inv.items[i].discountPercent) : '-', right: true),
                cell(qtyText(inv.items[i].taxPercent), right: true),
                cell(_n(inv.items[i].taxable), right: true),
              ]),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 5,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Tax summary', style: small),
                  pw.SizedBox(height: 3),
                  pw.Table(
                    border: border,
                    children: [
                      pw.TableRow(decoration: headFill, children: [
                        for (var i = 0; i < taxHead.length; i++) cell(taxHead[i], right: i > 0, head: true),
                      ]),
                      for (final r in taxRows)
                        pw.TableRow(children: [
                          for (var i = 0; i < r.length; i++) cell(r[i], right: i > 0),
                        ]),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 18),
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                children: [
                  totalRow('Gross amount', _m(inv.grossTotal, cur)),
                  if (inv.itemDiscounts > 0) totalRow('Item discount', '-${_m(inv.itemDiscounts, cur)}'),
                  if (inv.billDiscount > 0) totalRow('Bill discount', '-${_m(inv.billDiscount, cur)}'),
                  totalRow('Taxable value', _m(inv.taxableValue, cur)),
                  if (inter)
                    totalRow('IGST', _m(inv.igst, cur))
                  else ...[
                    totalRow('CGST', _m(inv.cgst, cur)),
                    totalRow('SGST', _m(inv.sgst, cur)),
                  ],
                  if (inv.roundOffAmount.abs() >= 0.005) totalRow('Round off', _m(inv.roundOffAmount, cur)),
                  pw.Divider(),
                  totalRow('Total', _m(inv.total, cur), strong: true),
                  totalRow('Received', _m(inv.paid, cur)),
                  totalRow('Balance due', _m(inv.balance, cur), strong: true),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text('Amount in words: ${amountInWords(inv.total, cur)}', style: bold),
        pw.SizedBox(height: 14),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (s.bankDetails.isNotEmpty) ...[
                    pw.Text('Bank details', style: small),
                    pw.Text(s.bankDetails, style: base),
                    pw.SizedBox(height: 6),
                  ],
                  if (s.upi.isNotEmpty) pw.Text('UPI: ${s.upi}', style: base),
                  if (inv.notes.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Text('Notes', style: small),
                    pw.Text(inv.notes, style: base),
                  ],
                  if (s.terms.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Text('Terms', style: small),
                    pw.Text(s.terms, style: base),
                  ],
                ],
              ),
            ),
            pw.SizedBox(width: 24),
            pw.Container(
              width: 170,
              height: 90,
              alignment: pw.Alignment.bottomCenter,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Divider(color: PdfColors.grey600),
                  pw.Text('For ${s.businessName}', style: base),
                  pw.Text('Authorised signatory', style: small),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}
