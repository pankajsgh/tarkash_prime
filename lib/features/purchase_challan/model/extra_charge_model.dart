import 'package:flutter/material.dart';

import '../../../core/ulitls/calculation.dart';
import '../../other_charges/data/model/other_charge_model.dart';
import 'purchase_model.dart';

class ExtraChargeModel {
  String id;
  ExtraChargeItemValue itemValue;
  OtherChargeModel? selectChargeName;
  double itemMultiplier =1;
  List<double> discountList = [];
  List<double> chargeList = [];


  ExtraChargeModel({
    required this.id,
    required this.itemValue,
    this.selectChargeName
  });

  Map<String, dynamic> toDataMap() {
    return itemValue.toMap();
  }

  Map<String, dynamic> toApiMap() {
    return itemValue.toJsonApi();
  }

  double taxAmount = 0;

  double setTaxAmount(List<PurchaseItem?> item) {

    var totalValue = itemValue.amount*itemMultiplier;

    if(itemValue.isDiscount)
      {
        if(itemValue.taxType!="Final Bill")
          {
            if(selectChargeName?.calculationType.trim()=='Per Main Qty')
            {
              discountList = distributeItemProportionally(totalAmount: totalValue, proportions: item.map((e)=> e==null? 0.0:e.quantity).toList());
            } else {
              discountList = distributePriceProportionally(totalAmount: totalValue, proportions: item.map((e)=> e==null? 0.0:e.getItemTotalAmount).toList());
            }
          } else {
          discountList = List.filled(item.length, 0.0);
        }

        taxAmount = 0;
        return taxAmount;
      }
    if(itemValue.taxType=="Final Bill")
      {
        taxAmount = 0;
        return taxAmount;
      }


    if(itemValue.isTaxApplicable)
    {
      taxAmount = totalValue * itemValue.taxPercent / 100;
      return taxAmount;
    } else {
      if(selectChargeName?.calculationType.trim()=='Per Main Qty')
        {
          chargeList = distributeItemProportionally(totalAmount: totalValue, proportions: item.map((e)=> e==null? 0.0:e.quantity).toList());
        } else {
          chargeList = distributePriceProportionally(totalAmount: totalValue, proportions: item.map((e)=> e==null? 0.0:e.getFinalPriceAfterDiscount).toList());
      }


      double tax = 0;
      for(var x=0; x<chargeList.length; x++)
        {
          var newTex = chargeList[x] * textToDouble(item[x]!=null? item[x]!.getGST:"0") / 100;
          tax += newTex;
        }
      taxAmount = tax;
      return tax;
    }
  }

  /// Amount including tax.
  double get totalAmount {
    return itemValue.amount*itemMultiplier + taxAmount;
  }

  double amountWith(double qty) {
    itemMultiplier = qty;
    return itemValue.amount*itemMultiplier;
  }


}

class ExtraChargeItemValue {
  String id;
  String name;
  double amount;
  String taxType;
  double taxPercent;
  bool isDiscount;
  bool isTaxApplicable;
  bool isItemQty;
  String itemWiseDistribution;

  ExtraChargeItemValue({
    required this.id,
    this.name = '',
    this.taxType='',
    this.amount = 0,
    this.taxPercent = 0,
    this.isDiscount = false,
    this.isTaxApplicable = false,
    this.isItemQty =false,
    this.itemWiseDistribution= 'Amount',
  });


  factory ExtraChargeItemValue.fromJson(Map<String, dynamic> map) {
    return ExtraChargeItemValue(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0,
      taxPercent: double.tryParse(map['taxPercent']?.toString() ?? '') ?? 0,
      taxType: map['taxType']?.toString() ?? '',
      isDiscount: map['isDiscount'] == true,
      isTaxApplicable: map['isTaxApplicable'] == true,
      itemWiseDistribution: map['itemWiseDistribution']?? 'Amount',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'taxPercent': taxPercent,
      'taxType': taxType,
      'isDiscount': isDiscount,
      'isTaxApplicable': isTaxApplicable,
      'itemWiseDistribution': itemWiseDistribution,
    };
  }

  Map<String, String> toJsonApi() {
    return {
      'id': id,
      'name': name,
      'amount': amount.toString(),
      'taxPercent': taxPercent.toString(),
      'taxType': taxType,
      'isDiscount': isDiscount? '1':'0',
      'isTaxApplicable': isTaxApplicable? '1':'0',
    };
  }
}