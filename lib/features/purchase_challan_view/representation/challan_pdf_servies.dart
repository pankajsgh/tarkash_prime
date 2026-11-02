
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../purchase_challan/model/purchase_challan_detail_model.dart';

class PurchaseChallanPdfService {
  static const PdfColor _black = PdfColor.fromInt(0xFF202020);
  static const PdfColor _text = PdfColor.fromInt(0xFF333333);
  static const PdfColor _muted = PdfColor.fromInt(0xFF707070);
  static const PdfColor _border = PdfColor.fromInt(0xFFD8D8D8);
  static const PdfColor _light = PdfColor.fromInt(0xFFF5F5F5);
  static const PdfColor _white = PdfColors.white;

  static const double _pagePadding = 24;

  Future<Uint8List> buildChallanPdf(
      PurchaseChallanDetails challan,
      ) async {
    final pdf = pw.Document(
      title: 'Purchase Challan ${_str(challan.challanNo)}',
      author: 'Globuzy Prime',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(
          _pagePadding,
          18,
          _pagePadding,
          23,
        ),
        maxPages: 100,
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        header: (context) => _pageHeader(),
        footer: (context) => _pageFooter(context),
        build: (context) => [
          _documentTitle(challan),
          pw.SizedBox(height: 7),
          _summaryStrip(challan),
          pw.SizedBox(height: 8),
          _detailsSection(challan),
          pw.SizedBox(height: 11),
          _sectionHeading('PRODUCT DETAILS'),
          pw.SizedBox(height: 5),
          _productTable(challan.items),
          pw.SizedBox(height: 10),
          _chargesAndTotals(challan),
          if (_str(challan.remark).isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _remarksSection(_str(challan.remark)),
          ],
          pw.SizedBox(height: 18),
          _signatureSection(),
        ],
      ),
    );

    return pdf.save();
  }

  // ------------------------------------------------------------
  // PAGE HEADER
  // ------------------------------------------------------------

  pw.Widget _pageHeader() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: _black,
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'GLOBUZY PRIME',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _black,
              letterSpacing: 0.5,
            ),
          ),
          pw.Text(
            'PURCHASE DOCUMENT',
            style: const pw.TextStyle(
              fontSize: 6.5,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DOCUMENT TITLE
  // ------------------------------------------------------------

  pw.Widget _documentTitle(PurchaseChallanDetails challan) {
    final reference = _str(challan.rereferenceNo).isNotEmpty
        ? _str(challan.rereferenceNo)
        : _str(challan.challanNo);

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: _black,
            width: 1.1,
          ),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PURCHASE CHALLAN',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _black,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Purchase inward document',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Container(
            constraints: const pw.BoxConstraints(maxWidth: 145),
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            decoration: pw.BoxDecoration(
              color: _light,
              border: pw.Border.all(
                color: _border,
                width: 0.7,
              ),
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'REFERENCE NO.',
                  style: const pw.TextStyle(
                    fontSize: 6,
                    color: _muted,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  _display(reference),
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SUMMARY BAND
  // ------------------------------------------------------------

  pw.Widget _summaryStrip(PurchaseChallanDetails challan) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      decoration: pw.BoxDecoration(
        color: _light,
        border: pw.Border.all(
          color: _border,
          width: 0.5,
        ),
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: _summaryValue(
              'CHALLAN NO.',
              _str(challan.challanNo),
            ),
          ),
          _summaryDivider(),
          pw.Expanded(
            flex: 5,
            child: _summaryValue(
              'CHALLAN DATE',
              _str(challan.challanDate),
            ),
          ),
          _summaryDivider(),
          pw.Expanded(
            flex: 3,
            child: _summaryValue(
              'TOTAL QTY.',
              _quantity(_totalQuantity(challan.items)),
            ),
          ),
          _summaryDivider(),
          pw.Expanded(
            flex: 4,
            child: _summaryValue(
              'GRAND TOTAL',
              _money(challan.grandTotal),
              highlight: true,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryValue(
      String label,
      String value, {
        bool highlight = false,
      }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 5.8,
            color: _muted,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          _display(value),
          maxLines: 2,
          style: pw.TextStyle(
            fontSize: highlight ? 8.5 : 7.5,
            fontWeight: pw.FontWeight.bold,
            color: _black,
          ),
        ),
      ],
    );
  }

  pw.Widget _summaryDivider() {
    return pw.Container(
      width: 0.5,
      height: 22,
      margin: const pw.EdgeInsets.symmetric(horizontal: 5),
      color: _border,
    );
  }

  // ------------------------------------------------------------
  // COMPACT TWO-COLUMN DETAILS
  // ------------------------------------------------------------

  pw.Widget _detailsSection(PurchaseChallanDetails challan) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 11,
              child: _detailCard(
                title: 'SUPPLIER DETAILS',
                rows: [
                  ['Supplier', _str(challan.company)],
                  ['Supplier ID', _str(challan.supplierId)],
                  ['GSTIN', _str(challan.gstNo)],
                ],
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              flex: 10,
              child: _detailCard(
                title: 'CHALLAN DETAILS',
                rows: [
                  ['Challan No.', _str(challan.challanNo)],
                  ['Reference', _str(challan.rereferenceNo)],
                  ['Date', _str(challan.challanDate)],
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 7),
        _detailCard(
          title: 'DELIVERY & TRANSPORT DETAILS',
          rows: [
            ['Store', _str(challan.storeName)],
            ['Transport', _str(challan.transportName)],
            ['Agent', _str(challan.agentName)],
            ['LR No.', _str(challan.lrNo)],
            ['LR Date', _str(challan.lrDate)],
          ],
          horizontal: true,
        ),
      ],
    );
  }

  pw.Widget _detailCard({
    required String title,
    required List<List<String>> rows,
    bool horizontal = false,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(7, 5, 7, 5),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: _border,
          width: 0.5,
        ),
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 6.7,
              fontWeight: pw.FontWeight.bold,
              color: _black,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Container(
            height: 0.5,
            color: _border,
          ),
          pw.SizedBox(height: 4),
          if (horizontal)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _horizontalDetailValue(
                      rows[i][0],
                      rows[i][1],
                    ),
                  ),
                ],
              ],
            )
          else
            for (final row in rows)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 57,
                      child: pw.Text(
                        row[0],
                        style: const pw.TextStyle(
                          fontSize: 6,
                          color: _muted,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Text(
                        _display(row[1]),
                        style: pw.TextStyle(
                          fontSize: 6.5,
                          fontWeight: pw.FontWeight.bold,
                          color: _text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  pw.Widget _horizontalDetailValue(
      String label,
      String value,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 5.8,
            color: _muted,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          _display(value),
          style: pw.TextStyle(
            fontSize: 6.5,
            fontWeight: pw.FontWeight.bold,
            color: _text,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SECTION HEADING
  // ------------------------------------------------------------

  pw.Widget _sectionHeading(String title) {
    return pw.Row(
      children: [
        pw.Container(
          width: 3,
          height: 10,
          color: _black,
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: _black,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PRODUCT TABLE - A4 PORTRAIT
  // ------------------------------------------------------------

  pw.Widget _productTable(List<dynamic> items) {
    const widths = <int, pw.TableColumnWidth>{
      0: pw.FixedColumnWidth(22),
      1: pw.FlexColumnWidth(3.8),
      2: pw.FixedColumnWidth(32),
      3: pw.FixedColumnWidth(30),
      4: pw.FixedColumnWidth(33),
      5: pw.FixedColumnWidth(45),
      6: pw.FixedColumnWidth(43),
      7: pw.FixedColumnWidth(55),
    };

    final rows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: const pw.BoxDecoration(
          color: _light,
        ),
        children: [
          _tableHeader('#'),
          _tableHeader('PRODUCT / BARCODE'),
          _tableHeader('HSN'),
          _tableHeader('QTY', right: true),
          _tableHeader('GST%', right: true),
          _tableHeader('RATE', right: true),
          _tableHeader('MRP', right: true),
          _tableHeader('AMOUNT', right: true),
        ],
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i.isEven ? _white : _light,
          ),
          children: [
            _tableCell('${i + 1}', center: true),
            _productCell(item),
            _tableCell(_str(item.hsn)),
            _tableCell(_quantity(item.itemQty), right: true),
            _tableCell(_str(item.gst), right: true),
            _tableCell(_money(item.amount), right: true),
            _tableCell(_money(item.mrp), right: true),
            _tableCell(
              _money(item.itemFinalPrice),
              right: true,
              bold: true,
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      rows.add(
        pw.TableRow(
          children: [
            _emptyCell(''),
            _emptyCell('No products found'),
            _emptyCell(''),
            _emptyCell(''),
            _emptyCell(''),
            _emptyCell(''),
            _emptyCell(''),
            _emptyCell(''),
          ],
        ),
      );
    }

    return pw.Table(
      columnWidths: widths,
      border: pw.TableBorder.all(
        color: _border,
        width: 0.5,
      ),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  pw.Widget _tableHeader(
      String value, {
        bool right = false,
      }) {
    return pw.Container(
      alignment: right
          ? pw.Alignment.centerRight
          : pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 6,
      ),
      child: pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 5.8,
          fontWeight: pw.FontWeight.bold,
          color: _black,
        ),
      ),
    );
  }

  pw.Widget _tableCell(
      String value, {
        bool right = false,
        bool center = false,
        bool bold = false,
      }) {
    return pw.Container(
      alignment: center
          ? pw.Alignment.center
          : right
          ? pw.Alignment.centerRight
          : pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 5,
      ),
      child: pw.Text(
        _display(value),
        style: pw.TextStyle(
          fontSize: 6.3,
          fontWeight: bold
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
          color: bold ? _black : _text,
        ),
      ),
    );
  }

  pw.Widget _emptyCell(String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        value,
        style: const pw.TextStyle(
          fontSize: 6.5,
          color: _muted,
        ),
      ),
    );
  }

  pw.Widget _productCell(dynamic item) {
    final productName = _str(item.productName);
    final barcode = _str(item.barcode);
    final size = _str(item.sizeName);
    final color = _str(item.colorName);

    final variant = [
      if (size.isNotEmpty) 'Size: $size',
      if (color.isNotEmpty) 'Color: $color',
    ].join(' | ');

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 3,
        vertical: 5,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _display(productName),
            style: pw.TextStyle(
              fontSize: 6.7,
              fontWeight: pw.FontWeight.bold,
              color: _black,
            ),
          ),
          if (barcode.isNotEmpty) ...[
            pw.SizedBox(height: 1),
            pw.Text(
              'Barcode: $barcode',
              style: const pw.TextStyle(
                fontSize: 5.5,
                color: _muted,
              ),
            ),
          ],
          if (variant.isNotEmpty) ...[
            pw.SizedBox(height: 1),
            pw.Text(
              variant,
              style: const pw.TextStyle(
                fontSize: 5.5,
                color: _muted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EXTRA CHARGES AND TOTALS
  // ------------------------------------------------------------

  pw.Widget _chargesAndTotals(
      PurchaseChallanDetails challan,
      ) {
    final charges = challan.extraCharge;
    final cgst = _number(challan.cgst);
    final sgst = _number(challan.sgst);
    final igst = _number(challan.igst);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeading('EXTRA CHARGES'),
        pw.SizedBox(height: 5),

        if (charges.isEmpty)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: _border,
                width: 0.5,
              ),
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Text(
              'No extra charges',
              style: const pw.TextStyle(
                fontSize: 6.5,
                color: _muted,
              ),
            ),
          )
        else
          pw.Table(
            border: pw.TableBorder.all(
              color: _border,
              width: 0.5,
            ),
            columnWidths: const {
              0: pw.FixedColumnWidth(23),
              1: pw.FlexColumnWidth(4),
              2: pw.FixedColumnWidth(75),
            },
            children: [
              pw.TableRow(
                repeat: true,
                decoration: const pw.BoxDecoration(
                  color: _light,
                ),
                children: [
                  _chargeHeader('#'),
                  _chargeHeader('CHARGE DESCRIPTION'),
                  _chargeHeader('AMOUNT', right: true),
                ],
              ),
              for (var i = 0; i < charges.length; i++)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i.isEven ? _white : _light,
                  ),
                  children: [
                    _chargeCell('${i + 1}'),
                    _chargeCell(_str(charges[i].name)),
                    _chargeCell(
                      _money(charges[i].amount),
                      right: true,
                      bold: true,
                    ),
                  ],
                ),
            ],
          ),

        pw.SizedBox(height: 8),

        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Container(
            width: 235,
            child: pw.Column(
              children: [
                _totalRow(
                  'Items Total',
                  _money(_itemsTotal(challan.items)),
                ),
                if (charges.isNotEmpty)
                  _totalRow(
                    'Extra Charges',
                    _money(_chargesTotal(charges)),
                  ),
                if (cgst != 0) _totalRow('CGST', _money(cgst)),
                if (sgst != 0) _totalRow('SGST', _money(sgst)),
                if (igst != 0) _totalRow('IGST', _money(igst)),
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _light,
                    border: pw.Border.all(
                      color: _black,
                      width: 0.7,
                    ),
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          'GRAND TOTAL',
                          style: pw.TextStyle(
                            fontSize: 7.5,
                            fontWeight: pw.FontWeight.bold,
                            color: _black,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 4),
                      pw.Text(
                        _money(challan.grandTotal),
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: _black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _chargeHeader(
      String value, {
        bool right = false,
      }) {
    return pw.Container(
      alignment: right
          ? pw.Alignment.centerRight
          : pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      child: pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 6,
          fontWeight: pw.FontWeight.bold,
          color: _black,
        ),
      ),
    );
  }

  pw.Widget _chargeCell(
      String value, {
        bool right = false,
        bool bold = false,
      }) {
    return pw.Container(
      alignment: right
          ? pw.Alignment.centerRight
          : pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      child: pw.Text(
        _display(value),
        style: pw.TextStyle(
          fontSize: 6.5,
          fontWeight: bold
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
          color: _text,
        ),
      ),
    );
  }

  pw.Widget _totalRow(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: _border,
            width: 0.5,
          ),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 7,
                color: _muted,
              ),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: _text,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // REMARKS
  // ------------------------------------------------------------

  pw.Widget _remarksSection(String remark) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(7),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: _border,
          width: 0.5,
        ),
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'REMARKS',
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: _black,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            remark,
            style: const pw.TextStyle(
              fontSize: 7,
              color: _text,
            ),
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
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(child: _signatureBox('Prepared By')),
        pw.SizedBox(width: 10),
        pw.Expanded(child: _signatureBox('Checked By')),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _signatureBox('Authorized Signature'),
        ),
      ],
    );
  }

  pw.Widget _signatureBox(String title) {
    return pw.Container(
      height: 40,
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: _border,
            width: 0.7,
          ),
        ),
      ),
      child: pw.Align(
        alignment: pw.Alignment.bottomCenter,
        child: pw.Text(
          title,
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(
            fontSize: 6.5,
            color: _muted,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FOOTER
  // ------------------------------------------------------------

  pw.Widget _pageFooter(pw.Context context) {
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
          pw.Text(
            'Globuzy Prime | Purchase Challan',
            style: const pw.TextStyle(
              fontSize: 6,
              color: _muted,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 6,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  String _str(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _display(String value) {
    return value.trim().isEmpty ? '-' : value.trim();
  }

  double _number(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();

    return double.tryParse(
      value.toString().replaceAll(',', '').trim(),
    ) ??
        0;
  }

  String _money(dynamic value) {
    final amount = _number(value);
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final integerPart = parts.first;
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    final isNegative = integerPart.startsWith('-');
    final digits = isNegative
        ? integerPart.substring(1)
        : integerPart;

    String grouped;

    if (digits.length <= 3) {
      grouped = digits;
    } else {
      final lastThree = digits.substring(digits.length - 3);
      var remaining = digits.substring(0, digits.length - 3);
      final groups = <String>[];

      while (remaining.length > 2) {
        groups.insert(
          0,
          remaining.substring(remaining.length - 2),
        );
        remaining = remaining.substring(
          0,
          remaining.length - 2,
        );
      }

      if (remaining.isNotEmpty) {
        groups.insert(0, remaining);
      }

      grouped = '${groups.join(',')},$lastThree';
    }

    return '${isNegative ? '-' : ''}$grouped.$decimalPart';
  }

  String _quantity(dynamic value) {
    final number = _number(value);

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(2);
  }

  double _totalQuantity(List<dynamic> items) {
    return items.fold<double>(
      0,
          (total, item) => total + _number(item.itemQty),
    );
  }

  double _itemsTotal(List<dynamic> items) {
    return items.fold<double>(
      0,
          (total, item) => total + _number(item.itemFinalPrice),
    );
  }

  double _chargesTotal(List<dynamic> charges) {
    return charges.fold<double>(
      0,
          (total, charge) => total + _number(charge.amount),
    );
  }
}
