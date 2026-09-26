import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

import '../../controller/extra_charge_controller.dart';
import '../../controller/purchase_controller.dart';

class ChallanPage extends StatelessWidget {
  final PurchaseController controller;
  final ExtraChargeController extraChargeController;

  const ChallanPage({
    super.key,
    required this.controller,
    required this.extraChargeController,
  });

  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color primary = Color(0xff2563EB);
  static const Color primaryDark = Color(0xff1D4ED8);

  static const Color background = Color(0xffF1F5F9);
  static const Color border = Color(0xffE2E8F0);
  static const Color borderDark = Color(0xffCBD5E1);

  static const Color textDark = Color(0xff0F172A);
  static const Color text = Color(0xff334155);
  static const Color textMuted = Color(0xff64748B);

  static const Color success = Color(0xff16A34A);
  static const Color danger = Color(0xffDC2626);

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: extraChargeController,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Scaffold(
              backgroundColor: background,
              appBar: _buildAppBar(context),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        22,
                        24,
                        24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1050,
                          ),
                          child: _buildChallanCard(),
                        ),
                      ),
                    ),
                  ),
                  _buildBottomBar(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // APP BAR
  // ===========================================================================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: textDark,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Purchase Challan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Goods receipt document',
                style: TextStyle(
                  fontSize: 10,
                  color: textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: _pdfButton(
            onPressed: () => _generatePdf(context),
            compact: true,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MAIN CHALLAN
  // ===========================================================================

  Widget _buildChallanCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: _buildChallanView(),
      ),
    );
  }

  Widget _buildChallanView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _challanHeader(),

        const SizedBox(height: 24),

        _sectionTitle(
          'CHALLAN INFORMATION',
          icon: Icons.info_outline_rounded,
        ),

        const SizedBox(height: 9),

        _challanInformation(),

        const SizedBox(height: 24),

        _sectionTitle(
          'PRODUCT DETAILS',
          icon: Icons.inventory_2_outlined,
          trailing: '${controller.items.length} Items',
        ),

        const SizedBox(height: 9),

        _productTable(),

        if (extraChargeController.items.isNotEmpty) ...[
          const SizedBox(height: 24),
          _extraChargeSection(),
        ],

        const SizedBox(height: 24),

        _summarySection(),

        const SizedBox(height: 20),

        _remarkSection(),

        const SizedBox(height: 55),

        _signatureSection(),
      ],
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _challanHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xffF8FAFC),
            Color(0xffEFF6FF),
          ],
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xffDBEAFE)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x222563EB),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PURCHASE CHALLAN',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .4,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Purchase / Goods Receipt Challan',
                  style: TextStyle(
                    fontSize: 11,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),

          _challanNumberBadge(),
        ],
      ),
    );
  }

  Widget _challanNumberBadge() {
    final number = controller.challanNo.trim().isEmpty
        ? 'CHALLAN'
        : controller.challanNo.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xffBFDBFE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'CHALLAN NO.',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: textMuted,
              letterSpacing: .4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _sectionTitle(
      String title, {
        IconData? icon,
        String? trailing,
      }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xffEFF6FF),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            icon ?? Icons.circle,
            size: 16,
            color: primary,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: textDark,
            letterSpacing: .5,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF8FAFC),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: border),
            ),
            child: Text(
              trailing,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // INFORMATION
  // ===========================================================================

  Widget _challanInformation() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderDark),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              _infoBox(
                'Challan No.',
                controller.challanNo,
                icon: Icons.tag_rounded,
              ),
              _infoDivider(),
              _infoBox(
                'Date',
                controller.selectedData,
                icon: Icons.calendar_today_outlined,
              ),
              _infoDivider(),
              _infoBox(
                'Supplier',
                _supplierName(),
                icon: Icons.business_outlined,
                flex: 2,
              ),
            ],
          ),
          _infoHorizontalDivider(),
          Row(
            children: [
              _infoBox(
                'GSTIN',
                controller.gstNo,
                icon: Icons.receipt_outlined,
              ),
              _infoDivider(),
              _infoBox(
                'Store',
                _storeName(),
                icon: Icons.store_outlined,
              ),
              _infoDivider(),
              _infoBox(
                'Transport',
                controller.selectedTransport?.transport ?? '',
                icon: Icons.local_shipping_outlined,
              ),
            ],
          ),
          _infoHorizontalDivider(),
          Row(
            children: [
              _infoBox(
                'LR No.',
                controller.lrNoController.text,
                icon: Icons.description_outlined,
              ),
              _infoDivider(),
              _infoBox(
                'LR Date',
                controller.lrDateController.text,
                icon: Icons.event_outlined,
              ),
              _infoDivider(),
              _infoBox(
                'Agent',
                controller.selectedAgent?.name ?? '',
                icon: Icons.person_outline_rounded,
                flex: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(
      String title,
      String value, {
        IconData? icon,
        int flex = 1,
      }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  icon,
                  size: 14,
                  color: primary,
                ),
              ),
            if (icon != null) const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 8,
                      color: textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value.trim().isEmpty ? '-' : value.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: textDark,
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

  Widget _infoDivider() {
    return Container(
      width: 1,
      height: 48,
      color: border,
    );
  }

  Widget _infoHorizontalDivider() {
    return Container(
      height: 1,
      color: border,
    );
  }

  // ===========================================================================
  // PRODUCT TABLE
  // ===========================================================================

  Widget _productTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderDark),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(42),
          1: FlexColumnWidth(3.3),
          2: FixedColumnWidth(62),
          3: FixedColumnWidth(80),
          4: FixedColumnWidth(62),
          5: FixedColumnWidth(65),
          6: FixedColumnWidth(95),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xffF8FAFC),
            ),
            children: [
              _tableHeaderCell('NO.'),
              _tableHeaderCell('PRODUCT', left: true),
              _tableHeaderCell('QTY'),
              _tableHeaderCell('RATE'),
              _tableHeaderCell('GST'),
              _tableHeaderCell('DISC.'),
              _tableHeaderCell('AMOUNT', right: true),
            ],
          ),

          ...List.generate(
            controller.items.length,
                (index) {
              final item = controller.items[index];

              return TableRow(
                decoration: BoxDecoration(
                  color: index.isEven
                      ? Colors.white
                      : const Color(0xffFCFDFE),
                ),
                children: [
                  _tableCell(
                    '${index + 1}',
                    center: true,
                  ),
                  _tableCell(
                    item.nameController.text.trim().isEmpty
                        ? '-'
                        : item.nameController.text.trim(),
                    bold: true,
                  ),
                  _tableCell(
                    item.quantityController.text,
                    center: true,
                  ),
                  _tableCell(
                    '₹ ${_money(item.productPrice ?? 0)}',
                    right: true,
                  ),
                  _tableCell(
                    '${item.getGST}%',
                    center: true,
                  ),
                  _tableCell(
                    '${item.discountController.text}%',
                    center: true,
                  ),
                  _tableCell(
                    '₹ ${_money(item.getFinalPriceAfterDiscount)}',
                    right: true,
                    bold: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(
      String text, {
        bool left = false,
        bool right = false,
      }) {
    return Container(
      height: 36,
      alignment: right
          ? Alignment.centerRight
          : left
          ? Alignment.centerLeft
          : Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderDark,
          ),
        ),
      ),
      child: Text(
        text,
        textAlign: right
            ? TextAlign.right
            : left
            ? TextAlign.left
            : TextAlign.center,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: textMuted,
          letterSpacing: .3,
        ),
      ),
    );
  }

  Widget _tableCell(
      String text, {
        bool right = false,
        bool center = false,
        bool bold = false,
      }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 39,
      ),
      alignment: right
          ? Alignment.centerRight
          : center
          ? Alignment.center
          : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: border,
          ),
        ),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: right
            ? TextAlign.right
            : center
            ? TextAlign.center
            : TextAlign.left,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: bold
              ? FontWeight.w700
              : FontWeight.w400,
        ),
      ),
    );
  }

  // ===========================================================================
  // EXTRA CHARGES
  // ===========================================================================

  Widget _extraChargeSection() {
    final items = extraChargeController.items;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'EXTRA CHARGES / DISCOUNTS',
          icon: Icons.tune_rounded,
          trailing: '${items.length} Applied',
        ),

        const SizedBox(height: 9),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderDark),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FixedColumnWidth(90),
              2: FixedColumnWidth(65),
              3: FixedColumnWidth(95),
              4: FixedColumnWidth(100),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xffF8FAFC),
                ),
                children: [
                  _tableHeaderCell(
                    'DESCRIPTION',
                    left: true,
                  ),
                  _tableHeaderCell('TYPE'),
                  _tableHeaderCell('AMOUNT'),
                  _tableHeaderCell(
                    'TAX AMOUNT',
                    right: true,
                  ),
                  _tableHeaderCell(
                    'TOTAL',
                    right: true,
                  ),
                ],
              ),
              ...items.map(
                    (item) {
                  return TableRow(
                    children: [
                      _tableCell(
                        item.itemValue.name.isEmpty
                            ? '-'
                            : item.itemValue.name,
                        bold: true,
                      ),
                      _tableCell(
                        item.itemValue.isDiscount
                            ? 'Discount'
                            : 'Charge',
                        center: true,
                      ),
                      _tableCell(
                        item.itemValue.amount.toString(),
                        center: true,
                      ),
                      _tableCell(
                        '₹ ${_money(
                          item.setTaxAmount(controller.items),
                        )}',
                        right: true,
                      ),
                      _tableCell(
                        '₹ ${_money(item.totalAmount)}',
                        right: true,
                        bold: true,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 9),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _smallSummary(
              'Charges',
              extraChargeController.totalCharges,
              danger,
            ),
            const SizedBox(width: 8),
            _smallSummary(
              'Discount',
              extraChargeController.totalDiscounts,
              success,
            ),
            const SizedBox(width: 8),
            _smallSummary(
              'Tax',
              extraChargeController.totalTax,
              primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _smallSummary(
      String title,
      double value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.05),
        border: Border.all(
          color: color.withOpacity(.20),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            '$title  ',
            style: TextStyle(
              fontSize: 8.5,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '₹ ${_money(value)}',
            style: TextStyle(
              fontSize: 9.5,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SUMMARY
  // ===========================================================================

  Widget _summarySection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _summaryLeft(),
        ),
        const SizedBox(width: 18),
        SizedBox(
          width: 350,
          child: _summaryRight(),
        ),
      ],
    );
  }

  Widget _summaryLeft() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: border),
                ),
                child: const Icon(
                  Icons.summarize_outlined,
                  size: 15,
                  color: primary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          _summaryLine(
            'Total Items',
            '${controller.totalItems}',
          ),
          _summaryLine(
            'Total Quantity',
            '${controller.totalQuantity}',
          ),
          _summaryLine(
            'Supplier',
            _supplierName(),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9.5,
              color: textMuted,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRight() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderDark),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _totalLine(
            'Value of Goods',
            controller.getTotalGoodsValue,
          ),
          _totalLine(
            'Additional Discount',
            controller.additionalDiscountTotal ?? 0,
            isDiscount: true,
          ),
          _totalLine(
            'Taxable Amount',
            controller.valueOfTaxableGoods(),
          ),
          _totalLine(
            'SGST',
            controller.sgst,
          ),
          _totalLine(
            'CGST',
            controller.cgst,
          ),
          if (extraChargeController.totalCharges > 0)
            _totalLine(
              'Extra Charges',
              extraChargeController.totalCharges,
              valueColor: danger,
            ),
          if (extraChargeController.totalDiscounts > 0)
            _totalLine(
              'Extra Discount',
              extraChargeController.totalDiscounts,
              isDiscount: true,
            ),
          if (extraChargeController.totalTax > 0)
            _totalLine(
              'Extra Tax',
              extraChargeController.totalTax,
            ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: const BoxDecoration(
              color: Color(0xffEFF6FF),
              border: Border(
                top: BorderSide(
                  color: Color(0xffBFDBFE),
                ),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GRAND TOTAL',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: primaryDark,
                          letterSpacing: .5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Final payable amount',
                        style: TextStyle(
                          fontSize: 8,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹ ${_money(_grandTotal)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalLine(
      String title,
      double value, {
        bool isDiscount = false,
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7.5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 9.5,
                color: textMuted,
              ),
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}₹ ${_money(value.abs())}',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: valueColor ??
                  (isDiscount ? success : text),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // REMARK
  // ===========================================================================

  Widget _remarkSection() {
    final remark = controller.remarkController.text.trim();

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: border),
            ),
            child: const Icon(
              Icons.notes_outlined,
              size: 15,
              color: textMuted,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REMARK',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: textMuted,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remark.isEmpty ? '-' : remark,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: text,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SIGNATURE
  // ===========================================================================

  Widget _signatureSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _Signature(
          title: 'Prepared By',
        ),
        _Signature(
          title: 'Checked By',
        ),
        _Signature(
          title: 'Authorized Signature',
        ),
      ],
    );
  }

  // ===========================================================================
  // BOTTOM BAR
  // ===========================================================================

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 11,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: border,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1050,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 10,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹ ${_money(_grandTotal)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(width: 18),
              _pdfButton(
                onPressed: () => _generatePdf(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pdfButton({
    required VoidCallback onPressed,
    bool compact = false,
  }) {
    return SizedBox(
      height: compact ? 38 : 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.picture_as_pdf_rounded,
          size: compact ? 16 : 18,
        ),
        label: Text(
          'Generate PDF',
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 13 : 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PDF
  // ===========================================================================

  Future<void> _generatePdf(BuildContext context) async {
    if (!_validate(context)) {
      return;
    }

    try {
      final Uint8List pdfBytes = await _createPdf();

      // Enable printing package when required.
      //
      // await Printing.layoutPdf(
      //   onLayout: (format) async => pdfBytes,
      // );

      debugPrint(
        'PDF generated successfully: ${pdfBytes.length} bytes',
      );
    } catch (e) {
      debugPrint('PDF generation error: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Failed to generate PDF: $e',
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // VALIDATION
  // ===========================================================================

  bool _validate(BuildContext context) {
    if (controller.challanNo.trim().isEmpty) {
      _showError(
        context,
        'Challan number is required',
      );
      return false;
    }

    if (controller.selectSupplier == null) {
      _showError(
        context,
        'Please select supplier',
      );
      return false;
    }

    if (controller.selectedStore == null) {
      _showError(
        context,
        'Please select store',
      );
      return false;
    }

    if (controller.items.isEmpty) {
      _showError(
        context,
        'Please add at least one product',
      );
      return false;
    }

    for (int i = 0; i < controller.items.length; i++) {
      final item = controller.items[i];

      if (item.product == null) {
        _showError(
          context,
          'Please select product in row ${i + 1}',
        );
        return false;
      }

      if (item.quantity <= 0) {
        _showError(
          context,
          'Invalid quantity in row ${i + 1}',
        );
        return false;
      }
    }

    return true;
  }

  void _showError(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  // ===========================================================================
  // CREATE PDF
  // ===========================================================================

  Future<Uint8List> _createPdf() async {
    final pdf = pw.Document();

    final font = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            _pdfHeader(font, boldFont),

            pw.SizedBox(height: 15),

            _pdfSectionTitle(
              'CHALLAN INFORMATION',
              boldFont,
            ),

            pw.SizedBox(height: 6),

            _pdfInfo(font, boldFont),

            pw.SizedBox(height: 15),

            _pdfSectionTitle(
              'PRODUCT DETAILS',
              boldFont,
            ),

            pw.SizedBox(height: 6),

            _pdfProducts(font, boldFont),

            if (extraChargeController.items.isNotEmpty) ...[
              pw.SizedBox(height: 15),
              _pdfSectionTitle(
                'EXTRA CHARGES / DISCOUNTS',
                boldFont,
              ),
              pw.SizedBox(height: 6),
              _pdfExtraCharges(font, boldFont),
            ],

            pw.SizedBox(height: 15),

            _pdfTotals(font, boldFont),

            pw.SizedBox(height: 15),

            _pdfRemark(font, boldFont),

            pw.SizedBox(height: 35),

            _pdfSignatures(boldFont),
          ];
        },
      ),
    );

    return Uint8List.fromList(
      await pdf.save(),
    );
  }

  // ===========================================================================
  // PDF HEADER
  // ===========================================================================

  pw.Widget _pdfHeader(
      pw.Font font,
      pw.Font boldFont,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(
          color: PdfColors.grey500,
        ),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 40,
            height: 40,
            color: PdfColors.blue700,
            child: pw.Center(
              child: pw.Text(
                'PC',
                style: pw.TextStyle(
                  font: boldFont,
                  color: PdfColors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
              pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PURCHASE CHALLAN',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 19,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Purchase / Goods Receipt Challan',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            color: PdfColors.blue50,
            child: pw.Text(
              controller.challanNo.isEmpty
                  ? 'CHALLAN'
                  : controller.challanNo,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 9,
                color: PdfColors.blue800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PDF SECTION
  // ===========================================================================

  pw.Widget _pdfSectionTitle(
      String title,
      pw.Font font,
      ) {
    return pw.Row(
      children: [
        pw.Container(
          width: 3,
          height: 12,
          color: PdfColors.blue700,
        ),
        pw.SizedBox(width: 6),
        pw.Text(
          title,
          style: pw.TextStyle(
            font: font,
            fontSize: 9,
            color: PdfColors.grey800,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PDF INFO
  // ===========================================================================

  pw.Widget _pdfInfo(
      pw.Font font,
      pw.Font boldFont,
      ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey500,
      ),
      columnWidths: const {
        0: pw.FixedColumnWidth(65),
        1: pw.FlexColumnWidth(2),
        2: pw.FixedColumnWidth(65),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        _pdfInfoRow(
          'Challan No.',
          controller.challanNo,
          'Date',
          controller.selectedData,
          font,
          boldFont,
        ),
        _pdfInfoRow(
          'Supplier',
          _supplierName(),
          'GSTIN',
          controller.gstNo,
          font,
          boldFont,
        ),
        _pdfInfoRow(
          'Store',
          _storeName(),
          'Transport',
          controller.selectedTransport?.transport ?? '',
          font,
          boldFont,
        ),
        _pdfInfoRow(
          'LR No.',
          controller.lrNoController.text,
          'LR Date',
          controller.lrDateController.text,
          font,
          boldFont,
        ),
        _pdfInfoRow(
          'Agent',
          controller.selectedAgent?.name ?? '',
          '',
          '',
          font,
          boldFont,
        ),
      ],
    );
  }

  pw.TableRow _pdfInfoRow(
      String title1,
      String value1,
      String title2,
      String value2,
      pw.Font font,
      pw.Font boldFont,
      ) {
    return pw.TableRow(
      children: [
        _pdfLabel(title1, boldFont),
        _pdfCell(value1, font),
        _pdfLabel(title2, boldFont),
        _pdfCell(value2, font),
      ],
    );
  }

  // ===========================================================================
  // PDF PRODUCTS
  // ===========================================================================

  pw.Widget _pdfProducts(
      pw.Font font,
      pw.Font boldFont,
      ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey500,
      ),
      columnWidths: const {
        0: pw.FixedColumnWidth(25),
        1: pw.FlexColumnWidth(3),
        2: pw.FixedColumnWidth(38),
        3: pw.FixedColumnWidth(58),
        4: pw.FixedColumnWidth(45),
        5: pw.FixedColumnWidth(45),
        6: pw.FixedColumnWidth(65),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue50,
          ),
          children: [
            _pdfHeaderCell('No.', boldFont),
            _pdfHeaderCell('Product', boldFont),
            _pdfHeaderCell('Qty', boldFont),
            _pdfHeaderCell('Rate', boldFont),
            _pdfHeaderCell('GST', boldFont),
            _pdfHeaderCell('Disc.', boldFont),
            _pdfHeaderCell('Amount', boldFont),
          ],
        ),
        ...List.generate(
          controller.items.length,
              (index) {
            final item = controller.items[index];

            return pw.TableRow(
              children: [
                _pdfCell(
                  '${index + 1}',
                  font,
                  center: true,
                ),
                _pdfCell(
                  item.nameController.text.isEmpty
                      ? '-'
                      : item.nameController.text,
                  font,
                ),
                _pdfCell(
                  item.quantityController.text,
                  font,
                  center: true,
                ),
                _pdfCell(
                  _money(item.productPrice ?? 0),
                  font,
                  right: true,
                ),
                _pdfCell(
                  '${item.getGST}%',
                  font,
                  center: true,
                ),
                _pdfCell(
                  '${item.discountController.text}%',
                  font,
                  center: true,
                ),
                _pdfCell(
                  _money(item.getFinalPriceAfterDiscount),
                  font,
                  right: true,
                  bold: true,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // PDF EXTRA CHARGES
  // ===========================================================================

  pw.Widget _pdfExtraCharges(
      pw.Font font,
      pw.Font boldFont,
      ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey500,
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FixedColumnWidth(75),
        2: pw.FixedColumnWidth(50),
        3: pw.FixedColumnWidth(65),
        4: pw.FixedColumnWidth(70),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
          ),
          children: [
            _pdfHeaderCell('Description', boldFont),
            _pdfHeaderCell('Type', boldFont),
            _pdfHeaderCell('Tax', boldFont),
            _pdfHeaderCell('Tax Amount', boldFont),
            _pdfHeaderCell('Total', boldFont),
          ],
        ),
        ...extraChargeController.items.map(
              (item) {
            return pw.TableRow(
              children: [
                _pdfCell(
                  item.itemValue.name.isEmpty
                      ? '-'
                      : item.itemValue.name,
                  font,
                ),
                _pdfCell(
                  item.itemValue.isDiscount
                      ? 'Discount'
                      : 'Charge',
                  font,
                  center: true,
                ),
                _pdfCell(
                  item.itemValue.isTaxApplicable
                      ? '${item.itemValue.taxPercent}%'
                      : '-',
                  font,
                  center: true,
                ),
                _pdfCell(
                  _money(
                    item.setTaxAmount(
                      controller.items,
                    ),
                  ),
                  font,
                  right: true,
                ),
                _pdfCell(
                  _money(item.totalAmount),
                  font,
                  right: true,
                  bold: true,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // PDF TOTALS
  // ===========================================================================

  pw.Widget _pdfTotals(
      pw.Font font,
      pw.Font boldFont,
      ) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        child: pw.Table(
          border: pw.TableBorder.all(
            color: PdfColors.grey500,
          ),
          children: [
            _pdfTotalRow(
              'Value of Good',
              controller.getTotalGoodsValue,
              font,
            ),
            _pdfTotalRow(
              'Additional Discount',
              controller.additionalDiscountTotal ?? 0,
              font,
            ),
            _pdfTotalRow(
              'Taxable amount',
              controller.valueOfTaxableGoods(),
              font,
            ),
            _pdfTotalRow(
              'SGST',
              controller.sgst,
              font,
            ),
            _pdfTotalRow(
              'CGST',
              controller.cgst,
              font,
            ),
            if (extraChargeController.totalCharges > 0)
              _pdfTotalRow(
                'Extra Charges',
                extraChargeController.totalCharges,
                font,
              ),
            if (extraChargeController.totalDiscounts > 0)
              _pdfTotalRow(
                'Extra Discount',
                -extraChargeController.totalDiscounts,
                font,
                discount: true,
              ),
            if (extraChargeController.totalTax > 0)
              _pdfTotalRow(
                'Extra Tax',
                extraChargeController.totalTax,
                font,
              ),
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue50,
              ),
              children: [
                _pdfTotalCell(
                  'GRAND TOTAL',
                  boldFont,
                ),
                _pdfTotalCell(
                  _money(_grandTotal),
                  boldFont,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.TableRow _pdfTotalRow(
      String title,
      double value,
      pw.Font font, {
        bool discount = false,
      }) {
    return pw.TableRow(
      children: [
        _pdfCell(
          title,
          font,
        ),
        _pdfCell(
          '${discount ? '-' : ''}${_money(value.abs())}',
          font,
          right: true,
        ),
      ],
    );
  }

  // ===========================================================================
  // PDF REMARK
  // ===========================================================================

  pw.Widget _pdfRemark(
      pw.Font font,
      pw.Font boldFont,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey500,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
        pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'REMARK',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 8,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            controller.remarkController.text.trim().isEmpty
                ? '-'
                : controller.remarkController.text.trim(),
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PDF SIGNATURES
  // ===========================================================================

  pw.Widget _pdfSignatures(
      pw.Font boldFont,
      ) {
    return pw.Row(
      mainAxisAlignment:
      pw.MainAxisAlignment.spaceBetween,
      children: [
        _pdfSignature(
          'Prepared By',
          boldFont,
        ),
        _pdfSignature(
          'Checked By',
          boldFont,
        ),
        _pdfSignature(
          'Authorized Signature',
          boldFont,
        ),
      ],
    );
  }

  pw.Widget _pdfSignature(
      String title,
      pw.Font font,
      ) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 25),
        pw.Container(
          width: 110,
          height: .7,
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          title,
          style: pw.TextStyle(
            font: font,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PDF CELLS
  // ===========================================================================

  pw.Widget _pdfHeaderCell(
      String text,
      pw.Font font,
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: 7,
        ),
      ),
    );
  }

  pw.Widget _pdfLabel(
      String text,
      pw.Font font,
      ) {
    return pw.Container(
      color: PdfColors.grey100,
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 7,
        ),
      ),
    );
  }

  pw.Widget _pdfCell(
      String text,
      pw.Font font, {
        bool right = false,
        bool center = false,
        bool bold = false,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: right
            ? pw.TextAlign.right
            : center
            ? pw.TextAlign.center
            : pw.TextAlign.left,
        style: pw.TextStyle(
          font: bold
              ? pw.Font.helveticaBold()
              : font,
          fontSize: 7,
        ),
      ),
    );
  }

  pw.Widget _pdfTotalCell(
      String text,
      pw.Font font,
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        style: pw.TextStyle(
          font: font,
          fontSize: 9,
        ),
      ),
    );
  }

  // ===========================================================================
  // VALUES
  // ===========================================================================

  String _supplierName() {
    return controller.selectSupplier?.name ?? '';
  }

  String _storeName() {
    return controller.selectedStore?.store ?? '';
  }

  double get _grandTotal {
    double total =
        controller.valueOfTaxableGoods()+
            controller.sgst +
            controller.cgst;

    total += extraChargeController.totalCharges;
    total -= extraChargeController.totalDiscounts;
    total += extraChargeController.totalTax;

    return total;
  }

  String _money(double value) {
    return value.toStringAsFixed(2);
  }
}

// =============================================================================
// SIGNATURE
// =============================================================================

class _Signature extends StatelessWidget {
  final String title;

  const _Signature({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        children: [
          const SizedBox(height: 28),
          Container(
            width: 125,
            height: 1,
            color: const Color(0xff475569),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xff334155),
            ),
          ),
        ],
      ),
    );
  }
}