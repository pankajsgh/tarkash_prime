import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../purchase_challan/model/purchase_challan_detail_model.dart';

const Color primaryColor = Color(0xFF3267D5);
const Color pageColor = Color(0xFFF4F6FA);
const Color textColor = Color(0xFF172033);
const Color mutedColor = Color(0xFF697586);
const Color borderColor = Color(0xFFE4E8EF);

const TextStyle _titleStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w600,
  color: textColor,
);

const TextStyle _sectionTitleStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: textColor,
);

const TextStyle _labelStyle = TextStyle(
  fontSize: 12,
  color: mutedColor,
);

const TextStyle _valueStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: textColor,
);

class PurchaseChallanDetailsScreen extends StatefulWidget {
  final PurchaseChallanDetails challan;

  const PurchaseChallanDetailsScreen({
    super.key,
    required this.challan,
  });

  @override
  State<PurchaseChallanDetailsScreen> createState() =>
      _PurchaseChallanDetailsScreenState();
}

class _PurchaseChallanDetailsScreenState
    extends State<PurchaseChallanDetailsScreen> {
  PurchaseChallanDetails get challan => widget.challan;

  String _str(dynamic value) => value?.toString().trim() ?? '';

  double _number(dynamic value) {
    return double.tryParse(
      value?.toString().replaceAll(',', '').trim() ?? '',
    ) ??
        0;
  }

// Monetary values always show two decimal places.
  String _money(dynamic value) => _number(value).toStringAsFixed(2);

// Quantities display as integers: 1, 2, 10 instead of 1.00, 2.00, 10.00.
  String _quantity(dynamic value) => _number(value).toInt().toString();

  String _display(dynamic value) {
    final valueText = _str(value);
    return valueText.isEmpty ? '—' : valueText;
  }

  String _reference() {
    final reference = _str(challan.rereferenceNo);
    if (reference.isNotEmpty) return reference;

    final number = _str(challan.challanNo);
    return number.isNotEmpty ? number : 'PURCHASE-CHALLAN';
  }

  List<dynamic> _items() => challan.items;

  List<dynamic> _charges() => challan.extraCharge;

  double _totalQuantity() {
    return _items().fold<double>(
      0,
          (sum, item) => sum + _number(item.itemQty),
    );
  }

  double _itemsTotal() {
    return _items().fold<double>(
      0,
          (sum, item) => sum + _number(item.amount),
    );
  }

  double _chargesTotal() {
    return _charges().fold<double>(
      0,
          (sum, item) => sum + _number(item.amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _topDetails(),
                        const SizedBox(height: 10),
                        _productSection(),
                        const SizedBox(height: 10),
                        _chargesAndTotals(),
                        const SizedBox(height: 10),
                        _remarks(),
                        const SizedBox(height: 10),
                        _bottomActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: textColor,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Purchase Challan',
                  style: _titleStyle,
                ),
                Text(
                  'Reference: ${_reference()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _labelStyle,
                ),
              ],
            ),
          ),
          _smallTag('${_items().length} Items'),
        ],
      ),
    );
  }

  Widget _topDetails() {
    Widget detailPanel(
        String title,
        IconData icon,
        List<(String, String)> rows,
        ) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: _panelDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: primaryColor),
                const SizedBox(width: 7),
                Text(title, style: _sectionTitleStyle),
              ],
            ),
            const SizedBox(height: 10),
            ...rows.map(
                  (row) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(row.$1, style: _labelStyle),
                    ),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: _valueStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 700;

        final challanPanel = detailPanel(
          'Challan Details',
          Icons.receipt_long,
          [
            ('Reference', _reference()),
            ('Challan No.', _display(challan.challanNo)),
            ('Date', _display(challan.challanDate)),
            ('LR No.', _display(challan.lrNo)),
            ('LR Date', _display(challan.lrDate)),
          ],
        );

        final supplierPanel = detailPanel(
          'Supplier',
          Icons.business_outlined,
          [
            ('Company', _display(challan.company)),
            ('Supplier ID', _display(challan.supplierId)),
            ('GSTIN', _display(challan.gstNo)),
          ],
        );

        final transportPanel = detailPanel(
          'Transport',
          Icons.local_shipping_outlined,
          [
            ('Store', _display(challan.storeName)),
            ('Transport', _display(challan.transportName)),
            ('Agent', _display(challan.agentName)),
          ],
        );

        final qr = InkWell(
          onTap: _showReferenceQr,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              border: Border.all(
                color: const Color(0xFFDCE6FA),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: _reference(),
                  width: 100,
                  height: 100,
                  drawText: false,
                ),
                const SizedBox(height: 5),
                const Text(
                  'REFERENCE QR',
                  style: TextStyle(
                    fontSize: 10,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _reference(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        );

        if (narrow) {
          return Column(
            children: [
              challanPanel,
              const SizedBox(height: 8),
              supplierPanel,
              const SizedBox(height: 8),
              transportPanel,
              const SizedBox(height: 8),
              qr,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  challanPanel,
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: supplierPanel),
                      const SizedBox(width: 8),
                      Expanded(child: transportPanel),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(width: 145, child: qr),
          ],
        );
      },
    );
  }

  void _showReferenceQr() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reference QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: _reference(),
              width: 220,
              height: 220,
              drawText: false,
            ),
            const SizedBox(height: 12),
            SelectableText(
              _reference(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: _reference()),
              );

              if (!dialogContext.mounted) return;

              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text('Reference copied'),
                ),
              );
            },
            child: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _productSection() {
    const labels = [
      '#',
      'PRODUCT',
      'BARCODE',
      'SIZE / COLOR',
      'BRAND',
      'HSN',
      'GST%',
      'QTY',
      'RATE',
      'MRP',
      'AMOUNT',
    ];

    const flexes = [3, 18, 9, 8, 8, 5, 4, 5, 7, 7, 8];

    return Container(
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: primaryColor,
                  size: 19,
                ),
                const Text(
                  'Product Details',
                  style: _sectionTitleStyle,
                ),
                _smallTag('${_items().length} Products'),
                _smallTag('Qty: ${_quantity(_totalQuantity())}'),
              ],
            ),
          ),
          const Divider(height: 1, color: borderColor),
          if (_items().isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No products found'),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1250,
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xFFF1F4F9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 11,
                      ),
                      child: Row(
                        children: List.generate(
                          labels.length,
                              (i) => Expanded(
                            flex: flexes[i],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                labels[i],
                                textAlign: i >= 7
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: mutedColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...List.generate(_items().length, (index) {
                      final item = _items()[index];

                      final values = [
                        '${index + 1}',
                        _display(item.productName),
                        _display(item.barcode),
                        '${_display(item.sizeName)} / ${_display(item.colorName)}',
                        _display(item.brand),
                        _display(item.hsn),
                        _display(item.gst),
                        _quantity(item.itemQty),
                        _money(item.itemFinalPrice),
                        _money(item.mrp),
                        _money(item.amount),
                      ];

                      return InkWell(
                        onTap: () => _showProductDetails(item, index),
                        child: Container(
                          color: index.isEven
                              ? Colors.white
                              : const Color(0xFFFAFBFD),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          child: Row(
                            children: List.generate(
                              values.length,
                                  (i) => Expanded(
                                flex: flexes[i],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    values[i],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: i >= 7
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textColor,
                                      fontWeight: (i == 1 ||
                                          i == 7 ||
                                          i == 10)
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showProductDetails(dynamic item, int index) {
    final details = <(String, String)>[
      ('Product', _display(item.productName)),
      ('Barcode', _display(item.barcode)),
      ('Brand', _display(item.brand)),
      ('Size', _display(item.sizeName)),
      ('Color', _display(item.colorName)),
      ('HSN', _display(item.hsn)),
      ('GST', '${_display(item.gst)}%'),
      ('Quantity', _quantity(item.itemQty)),
      ('Rate', _money(item.itemFinalPrice)),
      ('MRP', _money(item.mrp)),
      ('Wholesale', _money(item.wholesale)),
      ('Retail', _money(item.retail)),
      ('Amount', _money(item.amount)),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _display(item.productName),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  'Product ${index + 1}',
                  style: _labelStyle,
                ),
                const SizedBox(height: 12),
                ...details.map(
                      (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            entry.$1,
                            style: _labelStyle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.$2,
                            style: _valueStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chargesAndTotals() {
    final chargesCard = _card(
      title: 'Extra Charges',
      child: Column(
        children: [
          if (_charges().isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No extra charges added',
                style: _labelStyle,
              ),
            )
          else
            ..._charges().map(
                  (charge) => _amountRow(
                _display(charge.name),
                _money(charge.amount),
              ),
            ),
          const Divider(color: borderColor),
          _amountRow(
            'Total Extra Charges',
            _money(_chargesTotal()),
            bold: true,
          ),
        ],
      ),
    );

    final summaryCard = _card(
      title: 'Total Summary',
      child: Column(
        children: [
          _amountRow(
            'Item Quantity',
            _quantity(_totalQuantity()),
          ),
          _amountRow(
            'Item Amount',
            _money(_itemsTotal()),
          ),
          _amountRow(
            'Extra Charges',
            _money(_chargesTotal()),
          ),
          const Divider(color: borderColor),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tax Breakdown',
              style: _labelStyle,
            ),
          ),
          _amountRow('CGST', _money(challan.cgst)),
          _amountRow('SGST', _money(challan.sgst)),
          _amountRow('IGST', _money(challan.igst)),
          const Divider(color: borderColor),
          _amountRow(
            'Grand Total',
            _money(challan.grandTotal),
            bold: true,
            valueColor: primaryColor,
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              chargesCard,
              const SizedBox(height: 10),
              summaryCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: chargesCard),
            const SizedBox(width: 10),
            Expanded(flex: 4, child: summaryCard),
          ],
        );
      },
    );
  }

  Widget _card({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: _sectionTitleStyle),
          const SizedBox(height: 10),
          const Divider(height: 1, color: borderColor),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _amountRow(
      String label,
      String value, {
        bool bold = false,
        Color valueColor = textColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: _labelStyle),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: bold ? 14 : 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _remarks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remarks',
            style: _sectionTitleStyle,
          ),
          const SizedBox(height: 6),
          Text(
            _str(challan.remark).isEmpty
                ? '—'
                : _str(challan.remark),
            style: _labelStyle,
          ),
        ],
      ),
    );
  }

  Widget _bottomActions() {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 9,
      runSpacing: 9,
      children: [
        OutlinedButton.icon(
          onPressed: _showReferenceQr,
          icon: const Icon(
            Icons.qr_code_2_rounded,
            size: 18,
          ),
          label: const Text('Reference QR'),
        ),
        OutlinedButton.icon(
          onPressed: _printBarcodeLabels,
          icon: const Icon(
            Icons.barcode_reader,
            size: 18,
          ),
          label: const Text('Print Barcode Labels'),
        ),
        OutlinedButton.icon(
          onPressed: _viewChallanPdf,
          icon: const Icon(
            Icons.picture_as_pdf_rounded,
            size: 18,
          ),
          label: const Text('View PDF'),
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _printChallan,
          icon: const Icon(
            Icons.print_rounded,
            size: 18,
          ),
          label: const Text('Print Challan A4'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ],
    );
  }

// Both PDF preview and printing use these exact PDF bytes.
  Future<Uint8List> _buildChallanPdf() async {
    final pdf = pw.Document();

    const navy = PdfColor.fromInt(0xFF283747);
    const accent = PdfColor.fromInt(0xFF47718D);
    const paleBlue = PdfColor.fromInt(0xFFEDF3F7);
    const lightGrey = PdfColor.fromInt(0xFFF7F9FB);
    const border = PdfColor.fromInt(0xFFDCE3E9);
    const grey = PdfColor.fromInt(0xFF78838D);
    const black = PdfColor.fromInt(0xFF303943);
    const white = PdfColors.white;

    final items = _items();
    final charges = _charges();

    pw.Widget sectionHeading(
        String title, {
          String? trailing,
        }) {
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: pw.BoxDecoration(
          color: paleBlue,
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: navy,
                ),
              ),
            ),
            if (trailing != null)
              pw.Text(
                trailing,
                style: pw.TextStyle(
                  fontSize: 7,
                  color: grey,
                ),
              ),
          ],
        ),
      );
    }

    pw.Widget detailCard(
        String title,
        List<(String, String)> details,
        ) {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: white,
          border: pw.Border.all(
            color: border,
            width: 0.6,
          ),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            sectionHeading(title),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(8, 4, 8, 5),
              child: pw.Column(
                children: details.asMap().entries.map((entry) {
                  final label = entry.value.$1;
                  final value = entry.value.$2.trim().isEmpty
                      ? '-'
                      : entry.value.$2;

                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 3),
                    decoration: entry.key == details.length - 1
                        ? null
                        : const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: lightGrey,
                          width: 0.6,
                        ),
                      ),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(
                          width: 65,
                          child: pw.Text(
                            label,
                            style: const pw.TextStyle(
                              fontSize: 7,
                              color: grey,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 5),
                        pw.Expanded(
                          child: pw.Text(
                            value,
                            style: const pw.TextStyle(
                              fontSize: 7.5,
                              color: black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget chargeRow(String label, String amount) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                label,
                style: const pw.TextStyle(
                  fontSize: 7.8,
                  color: grey,
                ),
              ),
            ),
            pw.Text(
              amount,
              style: const pw.TextStyle(
                fontSize: 8,
                color: black,
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget totalRow(
        String label,
        String amount, {
          bool highlight = false,
        }) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        decoration: pw.BoxDecoration(
          color: highlight ? paleBlue : white,
          border: highlight
              ? const pw.Border(
            top: pw.BorderSide(
              color: border,
              width: 0.7,
            ),
          )
              : null,
        ),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: highlight ? 9 : 7.8,
                  color: highlight ? navy : grey,
                  fontWeight: highlight
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Text(
              amount,
              style: pw.TextStyle(
                fontSize: highlight ? 9 : 7.8,
                color: highlight ? navy : black,
                fontWeight: highlight
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(26, 22, 26, 28),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 9),
          padding: const pw.EdgeInsets.only(top: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(
                color: border,
                width: 0.6,
              ),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'PURCHASE CHALLAN  •  ${_reference()}',
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: grey,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: grey,
                ),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: border,
                  width: 0.8,
                ),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 4,
                  height: 48,
                  decoration: pw.BoxDecoration(
                    color: accent,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PURCHASE CHALLAN',
                        style: const pw.TextStyle(
                          fontSize: 16,
                          color: navy,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Goods receipt and purchase details',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: grey,
                        ),
                      ),
                      pw.SizedBox(height: 7),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: lightGrey,
                          border: pw.Border.all(
                            color: border,
                            width: 0.5,
                          ),
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          'Reference: ${_reference()}',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: border,
                      width: 0.6,
                    ),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: _reference(),
                    width: 52,
                    height: 52,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 9,
            ),
            decoration: pw.BoxDecoration(
              color: white,
              border: pw.Border.all(
                color: border,
                width: 0.6,
              ),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              children: [
                _pdfSummaryValue(
                  'CHALLAN NUMBER',
                  _display(challan.challanNo),
                ),
                _pdfSummaryDivider(),
                _pdfSummaryValue(
                  'CHALLAN DATE',
                  _display(challan.challanDate),
                ),
                _pdfSummaryDivider(),
                _pdfSummaryValue(
                  'TOTAL ITEMS',
                  '${items.length}',
                ),
                _pdfSummaryDivider(),
                _pdfSummaryValue(
                  'TOTAL QUANTITY',
                  _quantity(_totalQuantity()),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: detailCard(
                  'SUPPLIER DETAILS',
                  [
                    ('Company', _display(challan.company)),
                    ('Supplier ID', _display(challan.supplierId)),
                    ('GSTIN', _display(challan.gstNo)),
                  ],
                ),
              ),
              pw.SizedBox(width: 9),
              pw.Expanded(
                child: detailCard(
                  'DELIVERY DETAILS',
                  [
                    ('Store', _display(challan.storeName)),
                    ('Transport', _display(challan.transportName)),
                    ('Agent', _display(challan.agentName)),
                    ('LR Number', _display(challan.lrNo)),
                    ('LR Date', _display(challan.lrDate)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          sectionHeading(
            'PRODUCT DETAILS',
            trailing: '${items.length} products',
          ),
          if (items.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: border),
              ),
              child: pw.Center(
                child: pw.Text(
                  'No products found',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: grey,
                  ),
                ),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: [
                '#',
                'Product',
                'Barcode',
                'Size',
                'Color',
                'HSN',
                'GST%',
                'Qty',
                'Rate',
                'MRP',
                'Amount',
              ],
              data: List.generate(items.length, (index) {
                final item = items[index];

                return [
                  '${index + 1}',
                  _display(item.productName),
                  _display(item.barcode),
                  _display(item.sizeName),
                  _display(item.colorName),
                  _display(item.hsn),
                  _display(item.gst),
                  _quantity(item.itemQty),
                  _money(item.itemFinalPrice),
                  _money(item.mrp),
                  _money(item.amount),
                ];
              }),
              headerStyle: const pw.TextStyle(
                fontSize: 6.5,
                color: navy,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: paleBlue,
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 6,
                color: black,
              ),
              oddRowDecoration: const pw.BoxDecoration(
                color: lightGrey,
              ),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 2.5,
                vertical: 4,
              ),
              border: pw.TableBorder.all(
                color: border,
                width: 0.4,
              ),
              columnWidths: {
                0: const pw.FixedColumnWidth(17),
                1: const pw.FlexColumnWidth(2.6),
                2: const pw.FlexColumnWidth(1.8),
                3: const pw.FlexColumnWidth(0.8),
                4: const pw.FlexColumnWidth(0.8),
                5: const pw.FlexColumnWidth(1),
                6: const pw.FlexColumnWidth(0.65),
                7: const pw.FlexColumnWidth(0.75),
                8: const pw.FlexColumnWidth(1.1),
                9: const pw.FlexColumnWidth(1),
                10: const pw.FlexColumnWidth(1.2),
              },
              cellAlignments: {
                0: pw.Alignment.center,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
                8: pw.Alignment.centerRight,
                9: pw.Alignment.centerRight,
                10: pw.Alignment.centerRight,
              },
            ),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 5,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: border,
                      width: 0.6,
                    ),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      sectionHeading(
                        'EXTRA CHARGES',
                        trailing: '${charges.length} charges',
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          children: [
                            if (charges.isEmpty)
                              pw.Container(
                                width: double.infinity,
                                padding: const pw.EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: pw.Text(
                                  'No extra charges',
                                  style: const pw.TextStyle(
                                    fontSize: 8,
                                    color: grey,
                                  ),
                                ),
                              )
                            else
                              ...charges.map(
                                    (charge) => chargeRow(
                                  _display(charge.name),
                                  _money(charge.amount),
                                ),
                              ),
                            pw.Divider(
                              color: border,
                              thickness: 0.5,
                            ),
                            chargeRow(
                              'Total Extra Charges',
                              _money(_chargesTotal()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 9),
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: border,
                      width: 0.6,
                    ),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    children: [
                      sectionHeading('TOTAL SUMMARY'),
                      totalRow(
                        'Item Quantity',
                        _quantity(_totalQuantity()),
                      ),
                      totalRow(
                        'Item Amount',
                        _money(_itemsTotal()),
                      ),
                      totalRow(
                        'Extra Charges',
                        _money(_chargesTotal()),
                      ),
                      totalRow('CGST', _money(challan.cgst)),
                      totalRow('SGST', _money(challan.sgst)),
                      totalRow('IGST', _money(challan.igst)),
                      totalRow(
                        'Grand Total',
                        _money(challan.grandTotal),
                        highlight: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: border,
                width: 0.6,
              ),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                sectionHeading('REMARKS'),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    _str(challan.remark).isEmpty
                        ? '-'
                        : _str(challan.remark),
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: _pdfSignature('Prepared By'),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _pdfSignature('Checked By'),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _pdfSignature('Authorized Signatory'),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> _viewChallanPdf() async {
    try {
      final bytes = await _buildChallanPdf();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => Dialog(
          insetPadding: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 1100,
            height: MediaQuery.of(dialogContext).size.height * 0.94,
            child: Column(
              children: [
                Container(
                  height: 48,
                  padding: const EdgeInsets.only(
                    left: 14,
                    right: 6,
                  ),
                  color: const Color(0xFF283747),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Purchase Challan • ${_reference()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PdfPreview(
                    build: (_) async => bytes,
                    pdfFileName: 'Purchase_Challan_${_reference()}.pdf',
                    allowPrinting: true,
                    allowSharing: true,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    useActions: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to preview challan PDF: $e'),
        ),
      );
    }
  }

  Future<void> _printChallan() async {
    try {
      final bytes = await _buildChallanPdf();

      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'Purchase_Challan_${_reference()}.pdf',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to print challan PDF: $e'),
        ),
      );
    }
  }

  pw.Widget _pdfSignature(String label) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 8),
      padding: const pw.EdgeInsets.only(top: 38),
      child: pw.Column(
        children: [
          pw.Container(
            height: 0.7,
            color: const PdfColor.fromInt(0xFF9AA5AE),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            label,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromInt(0xFF303943),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryValue(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 6.5,
              color: PdfColor.fromInt(0xFF78838D),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 8.5,
              color: PdfColor.fromInt(0xFF303943),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryDivider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 6),
      width: 0.5,
      height: 25,
      color: const PdfColor.fromInt(0xFFDCE3E9),
    );
  }

  Future<void> _printBarcodeLabels() async {
    final validItems = _items()
        .where((item) => _str(item.barcode).isNotEmpty)
        .toList();

    if (validItems.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No product barcodes available to print'),
        ),
      );

      return;
    }

    final pdf = pw.Document();
    const labelsPerPage = 12;

    for (var start = 0; start < validItems.length; start += labelsPerPage) {
      final end = (start + labelsPerPage < validItems.length)
          ? start + labelsPerPage
          : validItems.length;

      final pageItems = validItems.sublist(start, end);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (context) => pw.GridView(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: pageItems.map((item) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(7),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey500,
                    width: 0.6,
                  ),
                ),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      _display(item.productName),
                      maxLines: 2,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: _str(item.barcode),
                      width: 130,
                      height: 36,
                      drawText: false,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      _str(item.barcode),
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'MRP: ${_money(item.mrp)}',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    try {
      await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
        name: 'Barcode_Labels_${_reference()}.pdf',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to print barcode labels: $e'),
        ),
      );
    }
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: borderColor),
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
