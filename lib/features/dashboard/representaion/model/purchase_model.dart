import 'package:calculation_panel/features/dashboard/model/product_model.dart';
import 'package:calculation_panel/features/dashboard/representaion/model/color_model.dart';
import 'package:calculation_panel/features/dashboard/representaion/model/size_model.dart';
import 'package:flutter/material.dart';

import '../../../../core/ulitls/calculation.dart';

class PurchaseItem {
  final String id;
  String? productId;
  ProductModel? product;
  ColorModel? color;
  SizeModel? size;

  FocusNode articleFocusNode = FocusNode();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController brandController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  final TextEditingController purchaseController = TextEditingController();

  final TextEditingController mrpRateController = TextEditingController();

  final TextEditingController wholesaleRateController = TextEditingController();

  final TextEditingController retailRateController = TextEditingController();

  final TextEditingController discountController = TextEditingController();

  final FocusNode productFocusNode = FocusNode();

  PurchaseItem({
    required this.id, required void Function() onChanged,
  });

  int get quantity => int.tryParse(quantityController.text) ?? 0;

  double get purchase => double.tryParse(purchaseController.text) ?? 0;

  double get discount => double.tryParse(discountController.text) ?? 0;

  double? amount;
  double itemFinalPrice = 0;
  double mrpPercent =18.0;
  double wholePercent =8.0;
  double retailPercent =12.0;

  void setAmount(){
    setMrpAmount();
    setWholesaleAmount();
    setRetailAmount();
    amount = calculatePriceAfterDiscount(price: textToDouble(purchaseController.text), discount: discount);
  }

  void setMrpAmount(){
    mrpRateController.text = calculatePriceAfterText(price: textToDouble(purchaseController.text), discount: mrpPercent).toString();
  }

  void setWholesaleAmount(){
    wholesaleRateController.text = calculatePriceAfterText(price: textToDouble(purchaseController.text), discount: wholePercent).toString();
  }

  void setRetailAmount(){
    retailRateController.text = calculatePriceAfterText(price: textToDouble(purchaseController.text), discount: retailPercent).toString();
  }


  double get getAmount {
    if(amount==null)
    {
      return 0.0;
    }
    return amount!*quantity;
  }


  String get getGST {
    if(product==null)
    {
      return '';
    }
    if(amount==null)
    {
      return '';
    }
    String tax = '0';
    for (final x in product!.hsnTaxSlab) {
      if (x.priceFrom.isNotEmpty && x.priceTo.isNotEmpty) {
        final from = double.tryParse(x.priceFrom) ?? 0.0;
        final to = double.tryParse(x.priceTo) ?? 0.0;

        if (amount! >= from && amount!<= to) {
          tax = x.tax?? '0';
          break; // stop after first matching element
        }
      }
    }
    return tax;
  }

  void dispose() {
    nameController.dispose();
    brandController.dispose();
    quantityController.dispose();
    purchaseController.dispose();
    mrpRateController.dispose();
    wholesaleRateController.dispose();
    retailRateController.dispose();
    discountController.dispose();
    productFocusNode.dispose();
  }
}