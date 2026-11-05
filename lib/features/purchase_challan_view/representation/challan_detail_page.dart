
import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../purchase_challan/model/purchase_challan_detail_model.dart';
import 'challan_pdf_servies.dart';

// ------------------------------------------------------------
// COMPACT THEME
// ------------------------------------------------------------

const Color primaryColor = Color(0xFF3267D5);
const Color pageColor = Color(0xFFF5F7FA);
const Color textColor = Color(0xFF263244);
const Color mutedColor = Color(0xFF788394);
const Color borderColor = Color(0xFFE3E8EF);
const Color headerColor = Color(0xFFF0F3F8);

const TextStyle _titleStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: textColor,
);

const TextStyle _sectionTitleStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: textColor,
);

const TextStyle _labelStyle = TextStyle(
  fontSize: 10.5,
  color: mutedColor,
);

const TextStyle _valueStyle = TextStyle(
  fontSize: 10.5,
  color: textColor,
  fontWeight: FontWeight.w500,
);

class PurchaseChallanDetailsScreen extends StatefulWidget {
  final PurchaseChallanDetails challan;
  final String title;

  const PurchaseChallanDetailsScreen({
    super.key,
    required this.challan,
    required this.title,
  });

  @override
  State<PurchaseChallanDetailsScreen> createState() =>
      _PurchaseChallanDetailsScreenState();
}

class _PurchaseChallanDetailsScreenState
    extends State<PurchaseChallanDetailsScreen> {
  PurchaseChallanDetails get challan => widget.challan;

  bool _showDetails = true;
  bool _showProducts = true;
  bool _showTotals = true;
  bool _showRemarks = true;

  String _str(dynamic value) => value?.toString().trim() ?? '';

  double _number(dynamic value) {
    return double.tryParse(
      value?.toString().replaceAll(',', '').trim() ?? '',
    ) ??
        0;
  }

  String _money(dynamic value) => _number(value).toStringAsFixed(2);

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
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _topDetails(),
                        const SizedBox(height: 6),
                        _productSection(),
                        const SizedBox(height: 6),
                        _chargesAndTotals(),
                        const SizedBox(height: 6),
                        _remarks(),
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
  Future<void> _previewPdf() async {
    try {
      final pdfBytes =
      await PurchaseChallanPdfService().buildChallanPdf(challan);

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to preview PDF: $e')),
      );
    }
  }
  // ------------------------------------------------------------
  // TOP BAR
  // ------------------------------------------------------------

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
            icon: const Icon(Icons.arrow_back_rounded, color: textColor),
          ),
          const SizedBox(width: 4),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: _titleStyle),
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
          const SizedBox(width: 8),

          IconButton(
            tooltip: 'Reference QR',
            onPressed: _showReferenceQr,
            icon: const Icon(Icons.qr_code_2, color: primaryColor),
          ),

          IconButton(
            tooltip: 'Print Barcode Labels',
            onPressed: _printBarcodeLabels,
            icon: const Icon(Icons.barcode_reader, color: primaryColor),
          ),

          IconButton(
            tooltip: 'View PDF',
            onPressed: _viewChallanPdf,
            icon: const Icon(Icons.picture_as_pdf, color: primaryColor),
          ),

          IconButton(
            tooltip: 'Print Challan A4',
            onPressed: _printChallan,
            icon: const Icon(Icons.print, color: primaryColor),
          ),
        ],
      ),
    );
  }


  // ------------------------------------------------------------
  // TOP DETAILS
  // ------------------------------------------------------------
  Widget _challanDetailPanel() {
    final rows = <(String, String)>[
      ('Reference', _reference()),
      ('Challan No.', _display(challan.challanNo)),
      ('Date', _display(challan.challanDate)),
      ('Agent', _display(challan.agentName)),
    ];

    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_outlined,
                size: 14,
                color: primaryColor,
              ),
              SizedBox(width: 5),
              Text('Challan Details', style: _sectionTitleStyle),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: rows.map((row) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 67,
                            child: Text(row.$1, style: _labelStyle),
                          ),
                          Expanded(
                            child: Text(
                              row.$2,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _valueStyle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: InkWell(
                  onTap: _showReferenceQr,
                  child: Column(
                    children: [
                      BarcodeWidget(
                        barcode: Barcode.qrCode(),
                        data: _reference(),
                        width: 80,
                        height: 80,
                        drawText: false,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'VIEW QR',
                        style: TextStyle(
                          fontSize: 8,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topDetails() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Challan Information',
            icon: Icons.receipt_long_outlined,
            expanded: _showDetails,
            onTap: () => setState(() => _showDetails = !_showDetails),
            trailing: _smallTag('QR Available'),
          ),
          if (_showDetails) ...[
            const Divider(height: 8, color: borderColor),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 7.0;

                final panels = <Widget>[
                  _challanDetailPanel(),
                  _detailPanel(
                    'Supplier',
                    Icons.business_outlined,
                    [
                      ('Company', _display(challan.company)),
                      ('Supplier ID', _display(challan.supplierId)),
                      ('GSTIN', _display(challan.gstNo)),
                    ],
                  ),
                  _detailPanel(
                    'Delivery',
                    Icons.local_shipping_outlined,
                    [
                      ('Store', _display(challan.storeName)),
                      ('Transport', _display(challan.transportName)),
                      ('LR No.', _display(challan.lrNo)),
                      ('LR Date', _display(challan.lrDate)),
                    ],
                  ),
                ];

                // Desktop/tablet: three panels in one left-aligned row.
                if (constraints.maxWidth >= 850) {
                  final panelWidth =
                      (constraints.maxWidth - (gap * 2)) / 3;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < panels.length; i++) ...[
                        SizedBox(
                          width: panelWidth,
                          child: panels[i],
                        ),
                        if (i != panels.length - 1)
                          const SizedBox(width: gap),
                      ],
                    ],
                  );
                }

                // Medium screens: two columns.
                if (constraints.maxWidth >= 560) {
                  final panelWidth =
                      (constraints.maxWidth - gap) / 2;

                  return Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: gap,
                    runSpacing: gap,
                    children: panels
                        .map(
                          (panel) => SizedBox(
                        width: panelWidth,
                        child: panel,
                      ),
                    )
                        .toList(),
                  );
                }

                // Small screens: one column, left aligned.
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < panels.length; i++) ...[
                      SizedBox(
                        width: constraints.maxWidth,
                        child: panels[i],
                      ),
                      if (i != panels.length - 1)
                        const SizedBox(height: gap),
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
  Widget _detailPanel(
      String title,
      IconData icon,
      List<(String, String)> rows,
      ) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: primaryColor),
              const SizedBox(width: 5),
              Text(title, style: _sectionTitleStyle),
            ],
          ),
          const SizedBox(height: 5),
          ...rows.map(
                (row) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 67,
                    child: Text(row.$1, style: _labelStyle),
                  ),
                  Expanded(
                    child: Text(
                      row.$2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _valueStyle,
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

  Widget _qrPanel() {
    return InkWell(
      onTap: _showReferenceQr,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFD),
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: _reference(),
              width: 65,
              height: 65,
              drawText: false,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Reference QR',
                    style: _sectionTitleStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _reference(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _labelStyle,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to enlarge',
                    style: TextStyle(
                      fontSize: 9,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReferenceQr() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Reference QR Code',
          style: TextStyle(fontSize: 15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: _reference(),
              width: 200,
              height: 200,
              drawText: false,
            ),
            const SizedBox(height: 10),
            SelectableText(
              _reference(),
              textAlign: TextAlign.center,
              style: _valueStyle,
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

  // ------------------------------------------------------------
  // PRODUCT TABLE
  // ------------------------------------------------------------

  Widget _productSection() {
    const labels = [
      '#',
      'PHOTO',
      'PRODUCT',
      'BARCODE',
      'SIZE / COLOR',
      'BRAND',
      'HSN',
      'GST%',
      'QTY',
      'RATE',
      'MRP',
      'TOTAL',
    ];

    // Keep the existing product table proportions.
    const flexes = [3, 5, 8, 9, 10, 8, 5, 4, 5, 7, 7, 8];

    return _panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 7,
            ),
            child: _sectionHeader(
              title: 'Product Details',
              icon: Icons.inventory_2_outlined,
              expanded: _showProducts,
              onTap: () => setState(
                    () => _showProducts = !_showProducts,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _smallTag('${_items().length} Products'),
                  const SizedBox(width: 5),
                  _smallTag('Qty: ${_quantity(_totalQuantity())}'),
                ],
              ),
            ),
          ),
          if (_showProducts) ...[
            const Divider(height: 1, color: borderColor),
            if (_items().isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No products found',
                    style: _labelStyle,
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1450,
                  child: Column(
                    children: [
                      Container(
                        color: headerColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        child: Row(
                          children: List.generate(
                            labels.length,
                                (i) => Expanded(
                              flex: flexes[i],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: Text(
                                  labels[i],
                                  textAlign: i >= 8
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: mutedColor,
                                    fontWeight: FontWeight.w600,
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
                          '',
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
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? Colors.white
                                  : const Color(0xFFFAFBFD),
                              border: const Border(
                                bottom: BorderSide(
                                  color: borderColor,
                                  width: 0.6,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Row(
                              children: List.generate(
                                values.length,
                                    (i) => Expanded(
                                  flex: flexes[i],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: i == 1
                                        ? Container(
                                      height: 29,
                                      width: 29,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: headerColor,
                                        borderRadius:
                                        BorderRadius.circular(3),
                                        border: Border.all(
                                          color: borderColor,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.image_outlined,
                                        size: 15,
                                        color: mutedColor,
                                      ),
                                    )
                                        : Text(
                                      values[i],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: i >= 8
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: textColor,
                                        fontWeight: (i == 2 ||
                                            i == 8 ||
                                            i == 11)
                                            ? FontWeight.w500
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.touch_app_outlined,
                    size: 13,
                    color: mutedColor,
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Tap a product row to view full details',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: mutedColor,
                      ),
                    ),
                  ),
                  Text(
                    'Total Qty: ${_quantity(_totalQuantity())}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.8,
          ),
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 3,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _display(item.productName),
                      style: _sectionTitleStyle,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close, size: 19),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Product ${index + 1}',
                  style: _labelStyle,
                ),
              ),
              const Divider(height: 12, color: borderColor),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: details
                        .map(
                          (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 105,
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
                    )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EXTRA CHARGES AND BILL SUMMARY
  // ------------------------------------------------------------

  Widget _chargesAndTotals() {
    final valueOfGoods = _number(challan.valueOfGood);
    final additionalDiscount =
    _number(challan.additionalDiscountTotal);
    final taxableAmount = _number(challan.taxableAmount);

    final discount =
        valueOfGoods - taxableAmount - additionalDiscount;

    final cgst = _number(challan.cgst);
    final sgst = _number(challan.sgst);
    final igst = _number(challan.igst);
    final additionalCharges =
    _number(challan.additionalChargeValue);
    final finalDiscount = _number(challan.finalDiscount);
    final grandTotal = _number(challan.grandTotal);

    final charges = _charges();

    final chargesCard = _summaryCard(
      title: 'Extra Charges',
      icon: Icons.add_card_outlined,
      trailing: _smallTag('${charges.length} Charges'),
      child: Column(
        children: [
          if (charges.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 9),
              child: Text(
                'No extra charges added',
                style: _labelStyle,
              ),
            )
          else
            ...charges.map(
                  (charge) => _amountRow(
                _display(charge.name),
                _money(charge.amount),
              ),
            ),
          if (additionalCharges != 0) ...[
            const Divider(height: 8, color: borderColor),
            _amountRow(
              'Total Extra Charges',
              _money(additionalCharges),
              bold: true,
            ),
          ],
        ],
      ),
    );

    final summaryRows = <Widget>[
      if (valueOfGoods != 0)
        _amountRow('Value of Goods', _money(valueOfGoods)),
      if (discount != 0)
        _amountRow('Discount', _money(discount)),
      if (additionalDiscount != 0)
        _amountRow(
          'Additional Discount',
          _money(additionalDiscount),
        ),
      if (taxableAmount != 0)
        _amountRow('Taxable Amount', _money(taxableAmount)),
      if (igst != 0) _amountRow('IGST', _money(igst)),
      if (sgst != 0) _amountRow('SGST', _money(sgst)),
      if (cgst != 0) _amountRow('CGST', _money(cgst)),
      if (additionalCharges != 0)
        _amountRow(
          'Additional Charges',
          _money(additionalCharges),
        ),
      if (finalDiscount != 0)
        _amountRow('Final Discount', _money(finalDiscount)),
      const Divider(height: 10, color: borderColor),
      _amountRow(
        'Grand Total',
        _money(grandTotal),
        bold: true,
        valueColor: primaryColor,
      ),
    ];

    final summaryCard = _summaryCard(
      title: 'Bill Summary',
      icon: Icons.receipt_outlined,
      trailing: _smallTag('Qty: ${_quantity(_totalQuantity())}'),
      child: Column(
        children: summaryRows,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              chargesCard,
              const SizedBox(height: 6),
              summaryCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: chargesCard),
            const SizedBox(width: 7),
            Expanded(flex: 4, child: summaryCard),
          ],
        );
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required IconData icon,
    required Widget trailing,
    required Widget child,
  }) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: primaryColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(title, style: _sectionTitleStyle),
              ),
              trailing,
            ],
          ),
          const Divider(height: 9, color: borderColor),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: mutedColor,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: bold ? 12 : 10.5,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // REMARKS
  // ------------------------------------------------------------

  Widget _remarks() {
    final remark = _str(challan.remark);

    return _panel(
      child: Column(
        children: [
          _sectionHeader(
            title: 'Remarks',
            icon: Icons.notes_outlined,
            expanded: _showRemarks,
            onTap: () => setState(
                  () => _showRemarks = !_showRemarks,
            ),
          ),
          if (_showRemarks) ...[
            const Divider(height: 8, color: borderColor),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                remark.isEmpty ? '—' : remark,
                style: _labelStyle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION HEADER
  // ------------------------------------------------------------

  Widget _sectionHeader({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: primaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(title, style: _sectionTitleStyle),
          ),
          if (trailing != null) ...[
            trailing,
            const SizedBox(width: 5),
          ],
          Icon(
            expanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            size: 18,
            color: mutedColor,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PDF PREVIEW
  // ------------------------------------------------------------

  Future<void> _viewChallanPdf() async {
    try {
      final Uint8List bytes =
      await PurchaseChallanPdfService().buildChallanPdf(challan);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => Dialog(
          insetPadding: const EdgeInsets.all(10),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: 1100,
            height: MediaQuery.of(dialogContext).size.height * 0.94,
            child: Column(
              children: [
                Container(
                  height: 42,
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  color: primaryColor,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Purchase Challan • ${_reference()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
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
      final Uint8List bytes =
      await PurchaseChallanPdfService().buildChallanPdf(challan);

      if (!mounted) return;

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

  // ------------------------------------------------------------
  // BARCODE LABEL PRINTING
  // ------------------------------------------------------------

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
      final bytes = await pdf.save();

      if (!mounted) return;

      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'Barcode_Labels_${_reference()}.pdf',
        format: PdfPageFormat.a4,
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

  // ------------------------------------------------------------
  // COMMON UI HELPERS
  // ------------------------------------------------------------

  Widget _panel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(8),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: child,
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: primaryColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: primaryColor),
        const SizedBox(width: 9),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
