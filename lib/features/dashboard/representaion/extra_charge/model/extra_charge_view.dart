import 'package:flutter/material.dart';

import '../../../../../core/widget/widget_updater.dart';
import '../../purchase_controller.dart';
import 'extra_charge_controller.dart';
import 'extra_charge_model.dart';

class ExtraChargeView extends StatelessWidget {
  const ExtraChargeView({
    super.key,
    required this.extraChargeController,
    required this.purchaseController,

  });

  final ExtraChargeController extraChargeController;
  final PurchaseController purchaseController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: extraChargeController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xffD6D6D6),
            ),
            borderRadius:
            BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _header(),
              _tableHeader(),
              _list(),
              _summary(),
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
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xffF7F8FA),
        borderRadius:
        BorderRadius.vertical(
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
              onPressed: extraChargeController.addItem,
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
              style:
              ElevatedButton.styleFrom(
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(4),
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
      height: 34,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xffE5E5E5),
          ),
          bottom: BorderSide(
            color: Color(0xffE5E5E5),
          ),
        ),
      ),
      child: Row(
        children: [
          _headerText(
            'Charge Name',
            3,
          ),
          _headerText(
            'Amount',
            2,
            right: true,
          ),
          _headerText(
            'Tax %',
            2,
            right: true,
          ),
          _headerText(
            'Tax',
            2,
            right: true,
          ),
          _headerText(
            'Total',
            2,
            right: true,
          ),
          _headerText(
            'Type',
            2,
            right: true,
          ),
          const SizedBox(
            width: 35,
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
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xff666666),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _list() {
    if (extraChargeController.items.isEmpty) {
      return Container(
        height: 120,
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
      height: 120,
      child: ListView.builder(
        itemCount:
        extraChargeController.items.length,
        itemBuilder: (context, index,) {
          final item = extraChargeController.items[index];
          return _row(item);
        },
      ),
    );
  }

  // ============================================================
  // ROW
  // ============================================================

  Widget _row(
      ExtraChargeModel item,
      ) {
    return Container(
      height: 34,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Row(
        children: [
          // NAME
          Expanded(
            flex: 4,
            child: _textField(
              controller:
              item.nameController,
              hint: 'Charge name',
              onChanged: (value) {
                extraChargeController.updateName(
                  item.id,
                  value,
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // AMOUNT
          Expanded(
            flex: 2,
            child: _textField(
              controller:
              item.amountController,
              hint: '0.00',
              number: true,
              onChanged: (value) {
                extraChargeController.updateAmount(
                  item.id,
                  value,
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // TAX %
          Expanded(
            flex: 2,
            child: _taxField(item),
          ),

          const SizedBox(width: 8),

          // TAX
          Expanded(
            flex: 2,
            child: _amount(item.setTaxAmount(purchaseController.items)),
          ),

          // TOTAL
          Expanded(
            flex: 2,
            child: _amount(
              item.totalAmount,
              bold: true,
            ),
          ),

          const SizedBox(width: 20),

          // TYPE
          Expanded(
            flex: 2,
            child: _typeDropdown(item),
          ),

          // DELETE
          SizedBox(
            width: 35,
            child: IconButton(
              onPressed: () {
                extraChargeController.deleteItem(
                  item.id,
                );
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
    );
  }

  // ============================================================
  // NORMAL TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController
    controller,
    required String hint,
    required ValueChanged<String>
    onChanged,
    bool number = false,
  }) {
    return SizedBox(
      height: 28,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: number
            ? const TextInputType
            .numberWithOptions(
          decimal: true,
        )
            : TextInputType.text,
        style: const TextStyle(
          fontSize: 11,
        ),
        textAlignVertical:
        TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 11,
            color: Color(0xffAAAAAA),
          ),
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 5,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Color(0xffD6D6D6),
            ),
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Color(0xffD6D6D6),
            ),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(4),
            borderSide: const BorderSide(
              color: Color(0xff4A90E2),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAX FIELD
  // ============================================================

  Widget _taxField(
      ExtraChargeModel item,
      ) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xffD6D6D6),
        ),
        borderRadius:
        BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          // SWITCH
          SizedBox(
            width: 32,
            height: 20,
            child: Center(
              child: Transform.scale(
                scale: 0.5,
                child: Switch(
                  value: item.isTaxApplicable,
                  onChanged: (value) {
                    if(!item.isDiscount)
                   {
                     extraChargeController.updateTaxType(
                       item.id,
                       value,
                     );
                   }
                  },
                  materialTapTargetSize:
                  MaterialTapTargetSize
                      .shrinkWrap,
                  thumbColor:
                  WidgetStateProperty.all(
                    Colors.white,
                  ),
                  trackColor:
                  WidgetStateProperty
                      .resolveWith<Color>(
                        (states) {
                      return states.contains(
                        WidgetState.selected,
                      )
                          ? Colors.green
                          : const Color(
                        0xffD6D6D6,
                      );
                    },
                  ),
                  trackOutlineColor:
                  WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          // TEXT FIELD
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: SizedBox(
                height: 28,
                child: TextFormField(
                  enabled: item.isTaxApplicable,
                  controller:
                  item.taxController,
                  onChanged: (value) {
                    extraChargeController.updateTax(
                      item.id,
                      value,
                    );
                  },
                  keyboardType:
                  const TextInputType
                      .numberWithOptions(
                    decimal: true,
                  ),
                  textAlignVertical:
                  TextAlignVertical.center,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1,
                  ),
                  decoration:
                  InputDecoration(
                    hintText: item.isTaxApplicable? 'Tax %':'auto',
                    hintStyle: TextStyle(
                      fontSize: 10,
                      color:
                      Color(0xffAAAAAA),
                    ),
                    border: InputBorder.none,
                    enabledBorder:
                    InputBorder.none,
                    focusedBorder:
                    InputBorder.none,
                    disabledBorder:
                    InputBorder.none,
                    contentPadding:
                    EdgeInsets.only(
                      left: 4,
                      right: 4,
                      top: 0,
                      bottom: 0,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
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
      }) {
    return Align(
      alignment:
      Alignment.centerRight,
      child: Text(
        value.toStringAsFixed(2),
        style: TextStyle(
          fontSize: 11,
          fontWeight: bold
              ? FontWeight.w600
              : FontWeight.normal,
          color:
          const Color(0xff333333),
        ),
      ),
    );
  }

  // ============================================================
  // TYPE DROPDOWN
  // ============================================================

  Widget _typeDropdown(
      ExtraChargeModel item,
      ) {
    return Container(
      height: 26,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xffD6D6D6),
        ),
        borderRadius:
        BorderRadius.circular(4),
      ),
      child:
      DropdownButtonHideUnderline(
        child: DropdownButton<bool>(
          value: item.isDiscount,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 14,
          ),
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xff333333),
          ),
          items: const [
            DropdownMenuItem(
              value: false,
              child: Text(
                'Charge',
              ),
            ),
            DropdownMenuItem(
              value: true,
              child: Text(
                'Discount',
              ),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            extraChargeController.updateType(
              item.id,
              value,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summary() {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      child:
      FutureBuilder(future: Future.delayed(Duration(milliseconds: 200)),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                mainAxisAlignment:
                MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey),
                        color: Colors.red.shade50

                    ),
                    child: Row(

                      children: [
                        _summaryItem(
                          'Tax',
                          extraChargeController.totalTax,
                        ),

                        const SizedBox(width: 20),

                        _summaryItem(
                          'Charges',
                          extraChargeController.totalCharges,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey),
                        color: Colors.green.shade50

                    ),
                    child: _summaryItem(
                      'Discount',
                      extraChargeController.totalDiscounts,
                    ),
                  ),

                  const SizedBox(width: 20),

                ],
              );
            }

            return Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey),
                      color: Colors.red.shade50

                  ),
                  child: Row(

                    children: [
                      _summaryItem(
                        'Tax',
                        extraChargeController.totalTax,
                      ),

                      const SizedBox(width: 20),

                      _summaryItem(
                        'Charges',
                        extraChargeController.totalCharges,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey),
                      color: Colors.green.shade50

                  ),
                  child: _summaryItem(
                    'Discount',
                    extraChargeController.totalDiscounts,
                  ),
                ),

                const SizedBox(width: 20),

              ],
            );}),



    );
  }

  Widget _summaryItem(
      String title,
      double value, {
        bool bold = false,
      }) {
    if(title=="Charges")
      {
        purchaseController.setAdditionalCharge(value);
      } else if (title=="Discount"){
        purchaseController.setAdditionalDiscount(value);
    }
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xff888888),
          ),
        ),
        const SizedBox(height: 1),
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