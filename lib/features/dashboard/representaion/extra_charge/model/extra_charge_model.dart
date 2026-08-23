import 'package:flutter/material.dart';

import '../../../../../core/ulitls/calculation.dart';
import '../../model/purchase_model.dart';

class ExtraChargeModel {
  final String id;

  String name;
  double amount;
  double taxPercent;

  /// false = Extra Charge
  /// true  = Extra Discount
  bool isDiscount;
  bool isTaxApplicable;

  late final TextEditingController nameController;
  late final TextEditingController amountController;
  late final TextEditingController taxController;

  ExtraChargeModel({
    required this.id,
    this.name = '',
    this.amount = 0,
    this.taxPercent = 0,
    this.isDiscount = false,
    this.isTaxApplicable = false,
  }) {
    nameController = TextEditingController(
      text: name,
    );

    amountController = TextEditingController(
      text: amount == 0
          ? ''
          : amount.toString(),
    );

    taxController = TextEditingController(
      text: taxPercent == 0
          ? ''
          : taxPercent.toString(),
    );
  }

  double taxAmount = 0;
  /// Tax calculated on amount.
  // double get taxAmount {
  //   return amount * taxPercent / 100;
  // }

  double setTaxAmount(List<PurchaseItem?> item) {
    if(isDiscount)
      {
        taxAmount = 0;
        return taxAmount;
      }
    if(isTaxApplicable)
    {
      taxAmount = amount * taxPercent / 100;
      return taxAmount;
    } else {
      List<double> listTax = distributeProportionally(totalAmount: amount, proportions: item.map((e)=> e==null? 0.0:e.getAmount).toList());
      double tax = 0;
      for(var x=0; x<listTax.length; x++)
        {
          var newTex = listTax[x] * textToDouble(item[x]!=null? item[x]!.getGST:"0") / 100;
          tax += newTex;
        }
      taxAmount = tax;
      return tax;
    }
  }

  /// Amount including tax.
  double get totalAmount {
    return amount + taxAmount;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'taxPercent': taxPercent,
      'isDiscount': isDiscount,
    };
  }

  factory ExtraChargeModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final amount =
        double.tryParse(
          map['amount']?.toString() ?? '',
        ) ??
            0;

    final taxPercent =
        double.tryParse(
          map['taxPercent']?.toString() ?? '',
        ) ??
            0;

    return ExtraChargeModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      amount: amount,
      taxPercent: taxPercent,
      isDiscount:
      map['isDiscount'] == true ||
          map['isDiscount'] == 1 ||
          map['isDiscount']?.toString() == '1',
    );
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    taxController.dispose();
  }
}