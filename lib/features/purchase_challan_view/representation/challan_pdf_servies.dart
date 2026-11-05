
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../purchase_challan/model/purchase_challan_detail_model.dart';

class PurchaseChallanPdfService {
  static const PdfColor _black = PdfColor.fromInt(0xFF222222);
  static const PdfColor _text = PdfColor.fromInt(0xFF444444);
  static const PdfColor _muted = PdfColor.fromInt(0xFF777777);
  static const PdfColor _border = PdfColor.fromInt(0xFFCCCCCC);
  static const PdfColor _light = PdfColor.fromInt(0xFFF5F5F5);
  static const PdfColor _white = PdfColors.white;

  static const double _fontSmall = 6;
  static const double _fontNormal = 7;
  static const double _fontTitle = 13;

  static pw.TextStyle _style({
    double size = _fontNormal,
    PdfColor color = _text,
  }) {
    return pw.TextStyle(
      fontSize: size,
      color: color,
      fontWeight: pw.FontWeight.normal,
    );
  }

  static pw.Text _textWidget(
      String value, {
        double size = _fontNormal,
        PdfColor color = _text,
        pw.TextAlign align = pw.TextAlign.left,
      }) {
    return pw.Text(
      value,
      textAlign: align,
      style: _style(size: size, color: color),
    );
  }

  Future<Uint8List> buildChallanPdf(
      PurchaseChallanDetails challan,
      ) async {
    final pdf = pw.Document();

    final items = challan.items;
    final charges = challan.extraCharge;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(18, 16, 18, 16),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helvetica(),
        ),
        header: (context) => _header(),
        footer: (context) => _footer(context),
        build: (context) => [
          _titleSection(challan),
          pw.SizedBox(height: 7),
          _challanSummary(challan),
          pw.SizedBox(height: 8),
          _detailsSection(challan),
          pw.SizedBox(height: 8),
          _sectionTitle('PRODUCT DETAILS'),
          pw.SizedBox(height: 4),
          _productTable(items),
          if (charges.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _sectionTitle('OTHER CHARGES'),
            pw.SizedBox(height: 4),
            _chargesTable(charges),
          ],
          pw.SizedBox(height: 8),
          _totalsSection(challan),
          if (_str(challan.remark).isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _remarksSection(challan.remark),
          ],
          pw.SizedBox(height: 18),
          _signatureSection(),
        ],
      ),
    );

    return pdf.save();
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  pw.Widget _header() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: _border,
            width: 0.6,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _textWidget(
            'GLOBUZY PRIME',
            size: 9,
            color: _black,
          ),
          _textWidget(
            'PURCHASE DOCUMENT',
            size: 6,
            color: _muted,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TITLE
  // ------------------------------------------------------------

  pw.Widget _titleSection(PurchaseChallanDetails challan) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _textWidget(
                'PURCHASE CHALLAN',
                size: _fontTitle,
                color: _black,
              ),
              pw.SizedBox(height: 2),
              _textWidget(
                'Goods receipt and purchase details',
                size: _fontSmall,
                color: _muted,
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: _border,
                width: 0.6,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _textWidget('REFERENCE NO.', size: 5, color: _muted),
                pw.SizedBox(height: 2),
                _textWidget(
                  _display(_str(challan.rereferenceNo)),
                  size: 8,
                  color: _black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CHALLAN SUMMARY
  // ------------------------------------------------------------

  pw.Widget _challanSummary(PurchaseChallanDetails challan) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 6,
      ),
      decoration: pw.BoxDecoration(
        color: _light,
        border: pw.Border.all(
          color: _border,
          width: 0.5,
        ),
      ),
      child: pw.Row(
        children: [
          _summaryItem('CHALLAN NO.', _str(challan.challanNo)),
          _verticalLine(),
          _summaryItem('DATE', _str(challan.challanDate)),
          _verticalLine(),
          _summaryItem(
            'TOTAL QTY',
            _quantity(_totalQuantity(challan.items)),
          ),
          _verticalLine(),
          _summaryItem(
            'GRAND TOTAL',
            _money(challan.grandTotal),
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryItem(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _textWidget(label, size: 5, color: _muted),
          pw.SizedBox(height: 3),
          _textWidget(value, size: 7, color: _black),
        ],
      ),
    );
  }

  pw.Widget _verticalLine() {
    return pw.Container(
      height: 19,
      width: 0.5,
      margin: const pw.EdgeInsets.symmetric(horizontal: 6),
      color: _border,
    );
  }

  // ------------------------------------------------------------
  // DETAILS
  // ------------------------------------------------------------

  pw.Widget _detailsSection(PurchaseChallanDetails challan) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _detailBox('SUPPLIER DETAILS', [
            _detailRow('Company', challan.company),
            _detailRow('Supplier ID', challan.supplierId),
            _detailRow('GST No.', challan.gstNo),
          ]),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: _detailBox('CHALLAN DETAILS', [
            _detailRow('Challan No.', challan.challanNo),
            _detailRow('Date', challan.challanDate),
            _detailRow('Reference', challan.rereferenceNo),
          ]),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: _detailBox('DELIVERY & TRANSPORT', [
            _detailRow('Store', challan.storeName),
            _detailRow('Transport', challan.transportName),
            _detailRow('Agent', challan.agentName),
            _detailRow('LR No.', challan.lrNo),
            _detailRow('LR Date', challan.lrDate),
          ]),
        ),
      ],
    );
  }
  pw.Widget _detailBox(String title, List<pw.Widget> children) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: _border,
          width: 0.5,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _textWidget(title, size: 6, color: _black),
          pw.SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _detailRow(String label, dynamic value) {
    final text = _display(_str(value));

    if (text == '-') {
      return pw.SizedBox.shrink();
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 65,
            child: _textWidget(
              label,
              size: _fontSmall,
              color: _muted,
            ),
          ),
          pw.Expanded(
            child: _textWidget(
              text,
              size: _fontSmall,
              color: _text,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  pw.Widget _sectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(
        bottom: 3,
        top: 2,
      ),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: _border,
            width: 0.6,
          ),
        ),
      ),
      child: _textWidget(
        title,
        size: 7,
        color: _black,
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCT TABLE
  // ------------------------------------------------------------

  pw.Widget _productTable(List items) {
    final rows = <pw.TableRow>[
      _tableHeader([
        '#',
        'PRODUCT / BARCODE',
        'HSN',
        'QTY',
        'GST%',
        'RATE',
        'MRP',
        'AMOUNT',
      ]),
    ];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      final productName = _display(_str(item.productName));
      final barcode = _str(item.barcode);
      final size = _str(item.sizeName);
      final color = _str(item.colorName);

      final variant = [
        if (size.isNotEmpty) 'Size: $size',
        if (color.isNotEmpty) 'Color: $color',
      ].join(' | ');

      final productDetails = [
        productName,
        if (barcode.isNotEmpty) 'Barcode: $barcode',
        if (variant.isNotEmpty) variant,
      ].join('\n');

      rows.add(
        _tableRow([
          '${i + 1}',
          productDetails,
          _str(item.hsn),
          _quantity(item.itemQty),
          _str(item.gst),
          _money(item.amount),
          _money(item.mrp),
          _money(item.itemFinalPrice),
        ]),
      );
    }

    if (items.isEmpty) {
      rows.add(
        _tableRow([
          '-',
          'No product details available',
          '-',
          '-',
          '-',
          '-',
          '-',
          '-',
        ]),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(
        color: _border,
        width: 0.4,
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(20),
        1: const pw.FlexColumnWidth(3.5),
        2: const pw.FlexColumnWidth(1.1),
        3: const pw.FlexColumnWidth(0.8),
        4: const pw.FlexColumnWidth(0.7),
        5: const pw.FlexColumnWidth(1.2),
        6: const pw.FlexColumnWidth(1.2),
        7: const pw.FlexColumnWidth(1.4),
      },
      children: rows,
    );
  }

  // ------------------------------------------------------------
  // TABLE HEADER
  // ------------------------------------------------------------

  pw.TableRow _tableHeader(List<String> labels) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        color: _light,
      ),
      children: labels.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;

        return pw.Container(
          alignment: index == 1
              ? pw.Alignment.centerLeft
              : pw.Alignment.center,
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 3,
            vertical: 5,
          ),
          child: _textWidget(
            label,
            size: 5.5,
            color: _black,
            align: index == 1
                ? pw.TextAlign.left
                : pw.TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  // ------------------------------------------------------------
  // TABLE ROW
  // ------------------------------------------------------------

  pw.TableRow _tableRow(List<String> values) {
    return pw.TableRow(
      children: values.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;

        return pw.Container(
          alignment: index == 1
              ? pw.Alignment.centerLeft
              : pw.Alignment.center,
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 3,
            vertical: 4,
          ),
          child: _textWidget(
            value,
            size: 5.5,
            color: _text,
            align: index == 1
                ? pw.TextAlign.left
                : pw.TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  // ------------------------------------------------------------
  // EXTRA CHARGES
  // ------------------------------------------------------------

  pw.Widget _chargesTable(List charges) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: _border,
        width: 0.4,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        _tableHeader(['CHARGE DESCRIPTION', 'AMOUNT']),
        ...charges.map<pw.TableRow>((charge) {
          return _tableRow([
            _display(_str(charge.name)),
            _money(charge.amount),
          ]);
        }),
      ],
    );
  }

  // ------------------------------------------------------------
  // TOTALS
  // ------------------------------------------------------------

  pw.Widget _totalsSection(PurchaseChallanDetails challan) {
    final itemsTotal = _itemsTotal(challan.items);
    final chargesTotal = _chargesTotal(challan.extraCharge);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _textWidget(
                'Total items: ${challan.items.length}',
                size: 6,
                color: _muted,
              ),
              pw.SizedBox(height: 3),
              _textWidget(
                'Total quantity: ${_quantity(_totalQuantity(challan.items))}',
                size: 6,
                color: _muted,
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 15),
        pw.SizedBox(
          width: 180,
          child: pw.Column(
            children: [
              _totalRow('Items Total', _money(itemsTotal)),
              if (chargesTotal != 0)
                _totalRow('Extra Charges', _money(chargesTotal)),
              if (_number(challan.cgst) != 0)
                _totalRow('CGST', _money(challan.cgst)),
              if (_number(challan.sgst) != 0)
                _totalRow('SGST', _money(challan.sgst)),
              if (_number(challan.igst) != 0)
                _totalRow('IGST', _money(challan.igst)),
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 4),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 5,
                ),
                decoration: pw.BoxDecoration(
                  color: _light,
                  border: pw.Border.all(
                    color: _border,
                    width: 0.5,
                  ),
                ),
                child: _totalRow(
                  'GRAND TOTAL',
                  _money(challan.grandTotal),
                  color: _black,
                  size: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _totalRow(
      String label,
      String value, {
        PdfColor color = _text,
        double size = 6,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _textWidget(label, size: size, color: color),
          _textWidget(value, size: size, color: color),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // REMARKS
  // ------------------------------------------------------------

  pw.Widget _remarksSection(dynamic remark) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: _border,
          width: 0.5,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _textWidget('REMARKS', size: 6, color: _muted),
          pw.SizedBox(height: 3),
          _textWidget(
            _str(remark),
            size: 6,
            color: _text,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SIGNATURES
  // ------------------------------------------------------------

  pw.Widget _signatureSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _signatureBox('PREPARED BY'),
        _signatureBox('CHECKED BY'),
        _signatureBox('AUTHORIZED SIGNATURE'),
      ],
    );
  }

  pw.Widget _signatureBox(String label) {
    return pw.Container(
      width: 105,
      padding: const pw.EdgeInsets.only(top: 22),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: _border,
            width: 0.6,
          ),
        ),
      ),
      child: _textWidget(
        label,
        size: 5.5,
        color: _muted,
        align: pw.TextAlign.center,
      ),
    );
  }

  // ------------------------------------------------------------
  // FOOTER
  // ------------------------------------------------------------

  pw.Widget _footer(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 7),
      padding: const pw.EdgeInsets.only(top: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: _border,
            width: 0.5,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _textWidget(
            'Globuzy Prime | Purchase Challan',
            size: 5.5,
            color: _muted,
          ),
          _textWidget(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            size: 5.5,
            color: _muted,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CALCULATIONS
  // ------------------------------------------------------------

  double _totalQuantity(List items) {
    double total = 0;

    for (final item in items) {
      total += _number(item.itemQty);
    }

    return total;
  }

  double _itemsTotal(List items) {
    double total = 0;

    for (final item in items) {
      total += _number(item.itemFinalPrice);
    }

    return total;
  }

  double _chargesTotal(List charges) {
    double total = 0;

    for (final charge in charges) {
      total += _number(charge.amount);
    }

    return total;
  }

  // ------------------------------------------------------------
  // FORMATTERS
  // ------------------------------------------------------------

  String _str(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _display(String value) {
    return value.isEmpty ? '-' : value;
  }

  double _number(dynamic value) {
    if (value == null) return 0;

    final cleaned = value
        .toString()
        .replaceAll(',', '')
        .replaceAll('₹', '')
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  String _money(dynamic value) {
    final amount = _number(value);
    final fixed = amount.abs().toStringAsFixed(2);
    final parts = fixed.split('.');

    String integerPart = parts[0];

    if (integerPart.length > 3) {
      final lastThree = integerPart.substring(
        integerPart.length - 3,
      );

      String remaining = integerPart.substring(
        0,
        integerPart.length - 3,
      );

      final buffer = StringBuffer();

      while (remaining.length > 2) {
        buffer.write(
          remaining.substring(remaining.length - 2),
        );
        buffer.write(',');

        remaining = remaining.substring(
          0,
          remaining.length - 2,
        );
      }

      if (remaining.isNotEmpty) {
        buffer.write(remaining);
        buffer.write(',');
      }

      integerPart = '${buffer.toString()}$lastThree';
    }

    final sign = amount < 0 ? '-' : '';

    return '$sign$integerPart.${parts[1]}';
  }

  String _quantity(dynamic value) {
    final number = _number(value);

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(2);
  }
}
