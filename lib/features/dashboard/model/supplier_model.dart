import 'package:calculation_panel/features/dashboard/model/product_model.dart';
import 'package:flutter/material.dart';

import '../../purchase_challan/model/color_model.dart';
import '../../purchase_challan/model/size_model.dart';

class PurchaseItem {
  final String id;
  String? productId;
  ProductModel? product;
  ColorModel? color;
  SizeModel? size;

  FocusNode articleFocusNode = FocusNode();

  final TextEditingController articleController = TextEditingController();

  final TextEditingController brandController = TextEditingController();

  final TextEditingController barcodeController = TextEditingController();

  final TextEditingController sizeController = TextEditingController();

  final TextEditingController colorController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  final TextEditingController purchaseController = TextEditingController();

  final TextEditingController netRateController = TextEditingController();

  final TextEditingController apRateController = TextEditingController();

  final TextEditingController dharaRateController = TextEditingController();

  final TextEditingController discountController = TextEditingController();

  final FocusNode productFocusNode = FocusNode();

  PurchaseItem({
    required this.id, required void Function() onChanged,
  });

  int get quantity => int.tryParse(quantityController.text) ?? 0;

  double get purchase =>
      double.tryParse(purchaseController.text) ?? 0;

  double get netRate =>
      double.tryParse(netRateController.text) ?? 0;

  double get discount =>
      double.tryParse(discountController.text) ?? 0;

  double? amount;

  String get getAmount {
    if(amount==null)
      {
        return '';
      }
    return (amount!*quantity).toStringAsFixed(2);
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
      if (x.priceFrom!.isNotEmpty && x.priceTo!.isNotEmpty) {
        final from = double.tryParse(x.priceFrom!) ?? 0.0;
        final to = double.tryParse(x.priceTo!) ?? 0.0;

        if (amount! >= from && amount!<= to) {
          tax = x.tax?? '0';
          print("Matched Tax: $tax");
          break; // stop after first matching element
        }
      }
    }
    return tax;
  }

  void dispose() {
    articleController.dispose();
    brandController.dispose();
    barcodeController.dispose();
    sizeController.dispose();
    colorController.dispose();
    quantityController.dispose();
    purchaseController.dispose();
    netRateController.dispose();
    apRateController.dispose();
    dharaRateController.dispose();
    discountController.dispose();

    productFocusNode.dispose();
  }
}