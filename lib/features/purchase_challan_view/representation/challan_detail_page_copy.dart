
import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../purchase_challan/model/purchase_challan_detail_model.dart';
import 'challan_pdf_servies.dart';

const Color primaryColor = Color(0xFF3267D5);
const Color pageColor = Color(0xFFF4F6FA);
const Color textColor = Color(0xFF172033);
const Color mutedColor = Color(0xFF697586);
const Color borderColor = Color(0xFFE4E8EF);

const TextStyle _titleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: textColor,
);

const TextStyle _sectionTitleStyle = TextStyle(
  fontSize: 13,
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
                        const SizedBox(height: 7),
                        _productSection(),
                        const SizedBox(height: 7),
                        _chargesAndTotals(),
                        const SizedBox(height: 7),
                        _remarks(),
                        const SizedBox(height: 7),
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

  // ------------------------------------------------------------
  // TOP BAR
  // ------------------------------------------------------------

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
          const SizedBox(width: 6),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _bottomActions(),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CHALLAN, SUPPLIER, DELIVERY AND QR DETAILS
  // ------------------------------------------------------------

  Widget _topDetails() {
    Widget detailPanel(
        String title,
        IconData icon,
        List<(String, String)> rows,
        ) {
      return Container(
        padding: const EdgeInsets.all(9),
        decoration: _panelDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _sectionTitleStyle.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...rows.map(
                  (row) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 67,
                      child: Text(
                        row.$1,
                        style: _labelStyle.copyWith(fontSize: 10),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _valueStyle.copyWith(fontSize: 10.5),
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

    final panels = <Widget>[
      detailPanel(
        'Challan Details',
        Icons.receipt_long,
        [
          ('Reference', _reference()),
          ('Challan No.', _display(challan.challanNo)),
          ('Date', _display(challan.challanDate)),
          ('Agent', _display(challan.agentName)),
        ],
      ),
      detailPanel(
        'Supplier',
        Icons.business_outlined,
        [
          ('Company', _display(challan.company)),
          ('Supplier ID', _display(challan.supplierId)),
          ('GSTIN', _display(challan.gstNo)),
        ],
      ),
      detailPanel(
        'Delivery',
        Icons.local_shipping_outlined,
        [
          ('Store', _display(challan.storeName)),
          ('Transport', _display(challan.transportName)),
          ('LR No.', _display(challan.lrNo)),
          ('LR Date', _display(challan.lrDate)),
        ],
      ),
      InkWell(
        onTap: _showReferenceQr,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            border: Border.all(color: const Color(0xFFDCE6FA)),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BarcodeWidget(
                barcode: Barcode.qrCode(),
                data: _reference(),
                width: 74,
                height: 74,
                drawText: false,
              ),
              const SizedBox(height: 4),
              const Text(
                'REFERENCE QR',
                style: TextStyle(fontSize: 9, color: mutedColor),
              ),
              const SizedBox(height: 2),
              Text(
                _reference(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;

        const gap = 8.0;

        final itemWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: panels
              .map((panel) => SizedBox(width: itemWidth, child: panel))
              .toList(),
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

    const flexes = [3, 5, 13, 9, 10, 8, 5, 4, 5, 7, 7, 8];

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
                width: 1260,
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xFFF1F4F9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
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
                                textAlign: i >= 8
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
                        '',
                        _display(item.productName),
                        _display(item.barcode),
                        '${_display(item.sizeName)} / ${_display(item.colorName)}',
                        _display(item.brand),
                        _display(item.hsn),
                        _display(item.gst),
                        _quantity(item.itemQty),
                        _money(item.amount),
                        _money(item.mrp),
                        _money(item.itemFinalPrice),
                      ];

                      return InkWell(
                        onTap: () => _showProductDetails(item, index),
                        child: Container(
                          color: index.isEven
                              ? Colors.white
                              : const Color(0xFFFAFBFD),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
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
                                  child: i == 1
                                      ? Container(
                                    height: 34,
                                    width: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F4F9),
                                      borderRadius:
                                      BorderRadius.circular(5),
                                      border: Border.all(
                                        color: borderColor,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 17,
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
                                      fontSize: 10.5,
                                      color: textColor,
                                      fontWeight: (i == 2 ||
                                          i == 8 ||
                                          i == 11)
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

  // ------------------------------------------------------------
  // EXTRA CHARGES AND TOTALS
  // ------------------------------------------------------------



  Widget _chargesAndTotals() {
    final itemQuantity = _totalQuantity();

    final valueOfGoods = _number(challan.valueOfGood);


    final additionalDiscount =
    _number(challan.additionalDiscountTotal);

    final taxableAmount = _number(challan.taxableAmount);
    final discount = valueOfGoods-taxableAmount-additionalDiscount;


    final cgst = _number(challan.cgst);
    final sgst = _number(challan.sgst);
    final igst = _number(challan.igst);

    final additionalCharges =
    _number(challan.additionalChargeValue);

    final finalDiscount = _number(challan.finalDiscount);

    final grandTotal = _number(challan.grandTotal);

    final charges = challan.extraCharge;

    // Extra Charges Card
    final chargesCard = _card(
      title: 'Extra Charges',
      itemQuantity: charges.length.toString(),
      child: Column(
        children: [
          if (charges.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No extra charges added',
                style: _labelStyle,
              ),
            )
          else
            ...charges.map(
                  (charge) => _amountRow(
                _display(charge.name),
                _money(_number(charge.amount)),
              ),
            ),

          const Divider(color: borderColor),

          if (additionalCharges != 0)
            _amountRow(
              'Total Extra Charges',
              _money(additionalCharges),
              bold: true,
            ),
        ],
      ),
    );

    // Bill Summary Card
    final summaryRows = <Widget>[
      if (valueOfGoods != 0)
        _amountRow(
          'Value of Goods',
          _money(valueOfGoods),
        ),

      if (discount != 0)
        _amountRow(
          'Discount',
          _money(discount),
        ),

      if (additionalDiscount != 0)
        _amountRow(
          'Additional Discount',
          _money(additionalDiscount),
        ),

      if (taxableAmount != 0)
        _amountRow(
          'Taxable Amount',
          _money(taxableAmount),
        ),

      if (igst != 0)
        _amountRow('IGST', _money(igst)),

      if (sgst != 0)
        _amountRow('SGST', _money(sgst)),

      if (cgst != 0)
        _amountRow('CGST', _money(cgst)),

      if (additionalCharges != 0)
        _amountRow(
          'Additional Charges',
          _money(additionalCharges),
        ),

      if (finalDiscount != 0)
        _amountRow(
          'Final Discount',
          _money(finalDiscount),
        ),

      const Divider(color: borderColor, height: 12),

      _amountRow(
        'Grand Total',
        _money(grandTotal),
        bold: true,
        valueColor: primaryColor,
      ),
    ];

    final summaryCard = _card(
      title: 'Bill Summary',
      itemQuantity: _quantity(itemQuantity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: summaryRows,
      ),
    );

    // Responsive Layout
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
            Expanded(
              flex: 5,
              child: chargesCard,
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: summaryCard,
            ),
          ],
        );
      },
    );
  }


  Widget _card({
    required String title,
    required String itemQuantity,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          SizedBox(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: _sectionTitleStyle.copyWith(fontSize: 12),
                  ),
                ),

                Text(
                  'Qty: ${_quantity(itemQuantity)}',
                  style: TextStyle(fontWeight: FontWeight.w500),                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
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
      padding: const EdgeInsets.all(9),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Remarks', style: _sectionTitleStyle),
          const SizedBox(height: 6),
          Text(
            _str(challan.remark).isEmpty ? '—' : _str(challan.remark),
            style: _labelStyle,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ACTION BUTTONS
  // ------------------------------------------------------------

  Widget _bottomActions() {
    final buttonStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
    );

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _showReferenceQr,
          icon: const Icon(Icons.qr_code_2_rounded, size: 15),
          label: const Text(
            'Reference QR',
            style: TextStyle(fontSize: 11),
          ),
          style: buttonStyle,
        ),
        OutlinedButton.icon(
          onPressed: _printBarcodeLabels,
          icon: const Icon(Icons.barcode_reader, size: 15),
          label: const Text(
            'Print Barcode Labels',
            style: TextStyle(fontSize: 11),
          ),
          style: buttonStyle,
        ),
        OutlinedButton.icon(
          onPressed: _viewChallanPdf,
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 15),
          label: const Text(
            'View PDF',
            style: TextStyle(fontSize: 11),
          ),
          style: buttonStyle.copyWith(
            foregroundColor: const WidgetStatePropertyAll(primaryColor),
            side: const WidgetStatePropertyAll(
              BorderSide(color: primaryColor),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _printChallan,
          icon: const Icon(Icons.print_rounded, size: 15),
          label: const Text(
            'Print Challan A4',
            style: TextStyle(fontSize: 11),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(
              horizontal: -1,
              vertical: -1,
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // A4 PDF: GENERATED BY PurchaseChallanPdfService
  // ------------------------------------------------------------

  Future<void> _viewChallanPdf() async {
    try {
      final Uint8List bytes = await PurchaseChallanPdfService().buildChallanPdf(challan);

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
                  padding: const EdgeInsets.only(left: 14, right: 6),
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
  // BARCODE LABEL PRINTING: KEPT IN THIS SCREEN
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
