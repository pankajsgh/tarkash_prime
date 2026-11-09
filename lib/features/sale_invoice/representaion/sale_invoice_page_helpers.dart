part of 'sale_invoice_page.dart';

extension _SaleInvoicePageHelpers on _SaleInvoicePageState {

InputDecoration _inputDecoration(
      String? hint, {
        IconData? prefix,
      }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: _SaleInvoicePageState.textLight,
      ),
      prefixIcon: prefix == null
          ? null
          : Icon(
        prefix,
        size: 16,
        color: _SaleInvoicePageState.textLight,
      ),
      prefixIconConstraints: prefix == null
          ? null
          : const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xff3B82F6),
          width: 1.3,
        ),
      ),
    );
  }

Widget _fieldBlock(
      String label,
      Widget field,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xff475569),
          ),
        ),

        const SizedBox(height: 5),

        field,
      ],
    );
  }

Widget _textField(
      TextEditingController textController, {
        String? hint,
        IconData? prefix,
      }) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: textController,
        decoration: this._inputDecoration(
          hint,
          prefix: prefix,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: _SaleInvoicePageState.textDark,
        ),
      ),
    );
  }

Widget _sectionTitle(
      IconData icon,
      String title,
      ) {
    return Row(
      children: [
        Container(
          height: 26,
          width: 26,
          decoration: BoxDecoration(
            color: const Color(0xffEAF2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: blue,
          ),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff1E293B),
          ),
        ),
      ],
    );
  }

Widget _buildChargesCard() {
    return this._bottomCard(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Charges & Tax',
      child: Column(
        children: [
          this._moneyRow(
            'Value of Goods',
            '₹ 0.00',
          ),

          this._moneyRow(
            'Discount',
            '₹ 0.00',
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              Expanded(
                child: this._dropdownField(
                  label: 'Other Charges',
                  value: otherCharge,
                  items: const [
                    'Other Charges',
                    'Freight',
                    'Transport',
                    'Packing',
                  ],
                  onChanged: (v) {
                    setState(() => otherCharge = v);
                  },
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 105,
                child: this._field(
                  label: 'Amount',
                  controller: otherChargeController,
                  hint: '0.00',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          this._moneyRow(
            'SGST',
            '₹ 0.00',
          ),

          this._moneyRow(
            'CGST',
            '₹ 0.00',
          ),

          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.only(top: 9),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xffE8EDF3),
                ),
              ),
            ),
            child: this._moneyRow(
              'Round Off (+/-)',
              '₹ 0.00',
              red: true,
            ),
          ),
        ],
      ),
    );
  }

Widget _summaryRow(
      String title,
      double value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '₹ ${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _SaleInvoicePageState.cardBorder,
        ),
      ),
      padding: padding,
      child: child,
    );
  }

Widget _bottomCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return this._card(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          this._sectionHeader(
            icon: icon,
            title: title,
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }

Widget _sectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        this._iconBox(icon),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _SaleInvoicePageState.textDark,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: _SaleInvoicePageState.textMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

Widget _iconBox(IconData icon) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        color: const Color(0xffEAF2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 16,
        color: _SaleInvoicePageState.primaryBlue,
      ),
    );
  }

Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    Widget? suffix,
    int maxLines = 1,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        this._fieldLabel(label),

        const SizedBox(height: 6),

        SizedBox(
          height: maxLines == 1 ? 36 : 72,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: isReadOnly,
            style: const TextStyle(
              fontSize: 11,
              color: _SaleInvoicePageState.textDark,
            ),
            decoration: this._decoration(
              hint: hint,
              suffix: suffix,
            ),
          ),
        ),
      ],
    );
  }

Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hint,
  }) {
    final safeValue =
    items.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        this._fieldLabel(label),

        const SizedBox(height: 6),

        SizedBox(
          height: 36,
          child: DropdownButtonFormField<String>(
            value: safeValue,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: _SaleInvoicePageState.textLight,
            ),
            style: const TextStyle(
              fontSize: 11,
              color: _SaleInvoicePageState.textDark,
            ),
            decoration: this._decoration(
              hint: hint,
            ),
            items: items.map(
                  (item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _SaleInvoicePageState.textDark,
                    ),
                  ),
                );
              },
            ).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

InputDecoration _decoration({
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 10,
        color: _SaleInvoicePageState.textLight,
      ),
      filled: true,
      fillColor: _SaleInvoicePageState.inputBg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      suffixIcon: suffix,
      suffixIconConstraints: suffix == null
          ? null
          : const BoxConstraints(
        minWidth: 34,
        minHeight: 34,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: _SaleInvoicePageState.cardBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: _SaleInvoicePageState.cardBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: _SaleInvoicePageState.primaryBlue,
          width: 1.2,
        ),
      ),
    );
  }

Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        color: _SaleInvoicePageState.textMedium,
      ),
    );
  }

Widget _moneyRow(
      String title,
      String amount, {
        bool red = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: red
                    ? const Color(0xffEF4444)
                    : _SaleInvoicePageState.textMedium,
                fontWeight:
                red ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 10,
              color: red
                  ? const Color(0xffEF4444)
                  : _SaleInvoicePageState.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

Widget _summaryMoneyRow(
      String title,
      String amount,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

Widget _filledButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

Widget _smallHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _SaleInvoicePageState.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: _SaleInvoicePageState.textMedium,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: _SaleInvoicePageState.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

void _resetForm() {
    setState(() {
      invoiceController.text = 'TN/26-27-3241';
      mobileController.clear();
      nameController.clear();
      gstController.clear();
      discountController.clear();
      caseController.clear();
      destinationController.clear();
      remarkController.clear();
      otherChargeController.clear();
      commissionController.clear();

      salesman = null;
      backman = null;
      supplier = null;
      transport = 'Transport';
      country = 'India';
      supply = 'Tamil Nadu';
      leadSource = null;
      agent = null;
      otherCharge = 'Other Charges';

      products
        ..clear()
        ..add(0);
    });
  }

void _submitSaleInvoice(bool isUpdate) {
    if (saleInvoiceController.isSubmitting) {
      return;
    }

    // ----------------------------------------------------------
    // SUPPLIER
    // ----------------------------------------------------------

    if (saleInvoiceController.selectSupplier == null) {
      Toast.show(message: 'Please select a supplier', type: .error);
      return;
    }

    if (saleInvoiceController.challanNo.trim().isEmpty) {
      Toast.show(message: 'Please Enter challan Nor', type: .error);
      return;
    }

    if (saleInvoiceController.selectedData.trim().isEmpty) {
      Toast.show(message: 'Please Select date', type: .error);
      return;
    }

    // ----------------------------------------------------------
    // ITEMS
    // ----------------------------------------------------------

    if (saleInvoiceController.items.isEmpty) {
      Toast.show(message: 'No product added', type: .error);
      return;
    }

    // ----------------------------------------------------------
    // VALIDATE EVERY PRODUCT
    // ----------------------------------------------------------

    for (int index = 0;
    index < saleInvoiceController.items.length;
    index++) {
      final item = saleInvoiceController.items[index];

      if (item.product == null) {
        Toast.show(message: 'Please select product for item ${index + 1}', type: .error);

        return;
      }

      if (item.product!.color == null) {
        Toast.show(message: 'Please select color for item ${index + 1}', type: .error);

        return;
      }

      if (item.product!.size == null) {
        Toast.show(message:'Please select size for item ${index + 1}', type: .error);

        return;
      }

      if (item.productPrice == null ||
          item.productPrice! <= 0) {
        Toast.show(message:  'Please enter amount for item ${index + 1}', type: .error);

        return;
      }
    }

    // saleInvoiceController.submitChallan(isUpdate);
  }

}
