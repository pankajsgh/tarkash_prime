import 'dart:async';

import 'package:calculation_panel/core/theme/colors.dart';
import 'package:flutter/material.dart';
import '../../../components/custome_dropdown_widget.dart';
import '../../../other_charges/data/model/other_charge_model.dart';
import '../../controller/purchase_controller.dart';
import '../../model/extra_charge_model.dart';

class ExtraChargeView extends StatefulWidget {
  const ExtraChargeView({
    super.key,
    required this.purchaseController,
  });

  final PurchaseController purchaseController;

  @override
  State<ExtraChargeView> createState() => _ExtraChargeViewState();
}

class _ExtraChargeViewState extends State<ExtraChargeView> {
  Timer? _searchDebounce;
  Timer? _debounce;

  PurchaseController get purchaseController => widget.purchaseController;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = purchaseController.extraChargeController;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xffD6D6D6),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _header(),
              _tableHeader(),
              _list(),

              FutureBuilder(
                future: Future.delayed(
                  const Duration(milliseconds: 500),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return _summary();
                  }

                  return _summary();
                },
              )
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xffF7F8FA),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Extra Charges / Discount',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 30,
            child: ElevatedButton.icon(
              onPressed: () {
               if(purchaseController.selectSupplier!=null)
                {
                  purchaseController.extraChargeController.addItem();
                }
              },
              icon: const Icon(
                Icons.add,
                size: 15,
              ),
              label: const Text(
                'Add',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _tableHeader() {
    return Container(
      height: 29,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: Color(0xffFBFBFC),
        border: Border(
          top: BorderSide(
            color: Color(0xffE9E9E9),
          ),
          bottom: BorderSide(
            color: Color(0xffE9E9E9),
          ),
        ),
      ),
      child: Row(
        children: [
          _headerText(
            'Charge',
            3,
          ),
          _headerText(
            'Per Qty / %',
            1,
            right: true,
          ),
          _headerText(
            'Amount',
            1,
            right: true,
          ),

          _headerText(
            'Type',
            2,
            right: true,
          ),
          _headerText(
            'Tax',
            1,
            right: true,
          ),
          _headerText(
            'Total',
            1,
            right: true,
          ),
          const SizedBox(
            width: 40,
          ),
        ],
      ),
    );
  }

  Widget _headerText(
      String text,
      int flex, {
        bool right = false,
      }) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: right
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xff777777),
          ),
        ),
      ),
    );
  }


  // ============================================================
  // LIST
  // ============================================================

  Widget _list() {
    final items = purchaseController.extraChargeController.items;

    if (items.isEmpty) {
      return Container(
        height: 130,
        alignment: Alignment.center,
        child: const Text(
          'No extra charge added',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xff999999),
          ),
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return _row(item);
        },
      ),
    );
  }

  // ============================================================
  // CHARGE NAME
  // ============================================================

  Widget _chargesName(ExtraChargeModel item) {
    final controller = purchaseController.extraChargeController;

    return ListenableBuilder(
      listenable: controller.updateCharges,
      builder: (context, _) {
        return SearchableCustomerDropdown<OtherChargeModel>(
          value: item.selectChargeName,
          height: 36,
          borderColor: Colors.grey.shade300,
          borderRadius: 4,
          dataFound: true,
          items: controller.searchCharges,
          onSearch: (value) {
            _searchDebounce?.cancel();

            _searchDebounce = Timer(
              const Duration(milliseconds: 500),
                  () async {
                await controller.searchOtherCharges(value);
              },
            );
          },
          displayString: (value) {
            return value.chargeName ?? '';
          },
          onSelect: (OtherChargeModel? value) {
            controller.setCharge(
              value,
              item,
            );
          },
        );
      },
    );
  }

  // ============================================================
  // ROW
  // ============================================================

  Widget _row(ExtraChargeModel item) {
    final chargeName = item.selectChargeName;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 1,
      ),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 1,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: chargeName == null
              ? Colors.transparent
              : item.itemValue.isDiscount
              ? colorGreenMid.withValues(alpha: 0.1)
              : colorRedMid.withValues(alpha: 0.1),
        ),
        child: Row(
          children: [
            // NAME
            Expanded(
              flex: 3,
              child: _chargesName(item),
            ),

            const SizedBox(width: 4),

        Expanded(
              flex: 1,
              child:  item.selectChargeName?.calculationType.trim()!= 'Amount'? YourWidget(
                  initValue: item.itemValue.amount.toString(),
                  hint: '0.00',
                  showSuffix: item.selectChargeName?.calculationType.trim() == 'Percentage (%)'?true:false ,
                  number: true,
                  onChanged: (value) {
                    purchaseController.extraChargeController.updateAmount(item.id, value,);
                  },
                  enable: true,
              ):SizedBox()
            ),
            // AMOUNT
            SizedBox(width: 4,),
            Expanded(
              flex:  1,
              child: YourWidget(
                enable: item.selectChargeName?.calculationType.trim() == "Amount",
                initValue: item.selectChargeName?.calculationType.trim() == "Amount"? item.amountWith(1).toString():
                item.selectChargeName?.calculationType.trim() == 'Percentage (%)'?  item.amountWith(purchaseController.getTotalGoodsValue/100).toString():
                item.amountWith(purchaseController.totalQuantity*1.0).toString(),
                hint: '0.00',
                number: true,
                onChanged: (value) {
                  purchaseController.extraChargeController.updateAmount(item.id, value,);
                },
              ),
            ),

            const SizedBox(width: 4),

            // TAX TYPE
            Expanded(
              flex: 2,
              child: _taxField(item),
            ),

            const SizedBox(width: 4),

            // TAX AMOUNT
            Expanded(
              flex: 1,
              child:  _amount(
                item.setTaxAmount(
                  purchaseController.items,
                ),
              )
            ),

            // TOTAL
            Expanded(
              flex: 1,
              child: _amount(
                item.totalAmount,
                bold: true,
                textColor: item.itemValue.isDiscount ? Colors.green: Colors.red
              ),
            ),

            // DELETE
            SizedBox(
              width: 36,
              child: IconButton(
                onPressed: () {
                  purchaseController
                      .extraChargeController
                      .deleteItem(item.id);
                },
                padding: EdgeInsets.zero,
                iconSize: 16,
                splashRadius: 16,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xffD32F2F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAX FIELD
  // ============================================================

  Widget _taxField(ExtraChargeModel item) {
    final taxType =
        '${item.itemValue.isDiscount ? 'discount: ' : ''} ${item.itemValue.taxType ?? ''}';

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 4),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              taxType,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
          ),
          if (taxType.trim()=='Separate') ...[
            const SizedBox(width: 6),
            Text(
              '${item.itemValue.taxPercent}%',
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  Widget _amount(
      double value, {
        bool bold = false,
        Color textColor = Colors.black,
      }) {


    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        value.toStringAsFixed(2),
        style: TextStyle(
          fontSize: 11,
          fontWeight: bold
              ? FontWeight.w600
              : FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summary() {

    final controller = purchaseController.extraChargeController;
    final totalTax = controller.totalTax;
    final totalCharges = controller.totalCharges;
    final totalDiscounts = controller.totalDiscountsWithOutFinal;
    final finalDiscount = controller.totalDiscountsWithFinal;

    purchaseController.setFinalDiscount(finalDiscount.toString());
    purchaseController.setAdditionalDiscount(totalDiscounts);
    purchaseController.setAdditionalDiscountByCat(controller.discountListsByCat());

    purchaseController.setAdditionalCharge(totalCharges);
    print("this is good 55555");
    print(controller.totalChargeListsByCat());
    purchaseController.setAdditionalChargeByCat(controller.totalChargeListsByCat());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      purchaseController.updateSummery.update();
    });

    // Do not call setters here.
    // Build methods should not change controller state.

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // TAX AND CHARGES
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey,
              ),
              color: Colors.red.shade50,
            ),
            child: Row(
              children: [
                _summaryItem(
                  'Tax',
                  totalTax,
                ),
                const SizedBox(width: 20),
                _summaryItem(
                  'Charges',
                  totalCharges,
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // DISCOUNTS
          if(totalDiscounts > 0 || finalDiscount > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey,
              ),
              color: Colors.green.shade50,
            ),
            child: Row(
              children: [
                if (totalDiscounts > 0)
                  _summaryItem(
                    'Discount',
                    totalDiscounts,
                  ),

                if (totalDiscounts > 0 &&
                    finalDiscount > 0)
                  const SizedBox(width: 12),

                if (finalDiscount > 0)
                  _summaryItem(
                    'Final discount',
                    finalDiscount,
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _summaryItem(
      String title,
      double value, {
        bool bold = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xff888888),
          ),
        ),
        Text(
          '₹ ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: bold
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class YourWidget extends StatefulWidget {
  final String initValue;
  final bool number;
  final String hint;
  final bool enable;
  final bool showSuffix;
  final ValueChanged<String> onChanged;

  const YourWidget({
    super.key,
    required this.initValue,
    required this.number,
    required this.hint,
    required this.enable,
    required this.onChanged,
    this.showSuffix = false
  });

  @override
  State<YourWidget> createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initValue);
  }

  @override
  void didUpdateWidget(covariant YourWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initValue != widget.initValue &&
        _controller.text != widget.initValue) {
      _controller.text = widget.initValue;

      // Optional: keep cursor at the end
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: TextFormField(
        enabled: widget.enable,
        controller: _controller,
        onChanged: (value) {
          _debounce?.cancel();

          _debounce = Timer(
            const Duration(milliseconds: 500),
                () {
              widget.onChanged(value);
            },
          );
        },
        keyboardType: widget.number
            ? const TextInputType.numberWithOptions(
          decimal: true,
        )
            : TextInputType.text,
        style: const TextStyle(
          fontSize: 11,
        ),
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          suffix: widget.showSuffix? Text("%"):null,
          hintText: widget.hint,
          hintStyle: const TextStyle(
            fontSize: 11,
            color: Color(0xffAAAAAA),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 5,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Color(0xffD6D6D6),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Color(0xffD6D6D6),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Color(0xff4A90E2),
            ),
          ),
        ),
      ),
    );
  }
}