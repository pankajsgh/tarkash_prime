

import 'package:flutter/material.dart';
import '../../../core/ulitls/calculation.dart';
import '../../purchase_challan/model/product_model.dart';

class SaleItem {
  final String id;
  ProductModel? product;
  FocusNode articleFocusNode = FocusNode();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final FocusNode productFocusNode = FocusNode();

  SaleItem({
    required this.id, required void Function() onChanged,
    this.product,
    this.extraDiscount = 0,
    this.extraCharge = 0,
  }){
    if(product!=null)
    {
      nameController.text = product!.name;
      brandController.text = product!.brand!=null? product!.brand!.name?? '':'';
      quantityController.text = product!.qty?? '';
      priceController.text = product!.purchaseRate ?? '';
      discountController.text =product!.discount?? '';
      setDiscountedAmount();
    }
  }

  int get quantity => int.tryParse(quantityController.text) ?? 0;
  double get discount => double.tryParse(discountController.text) ?? 0;
  double? productPrice;
  double extraDiscount = 0;
  double extraCharge = 0;
  double _itemFinalPrice = 0;
  double mrpPercent =18.0;
  double wholePercent =8.0;
  double retailPercent =12.0;


  void setDiscountedAmount() {
    // Update the current selling price and calculated invoice amount.
    productPrice = textToDouble(priceController.text);

    if (product != null) {
      product!.qty = quantityController.text;
      product!.purchaseRate = priceController.text;
      product!.discount = discountController.text;
    }
  }



  double get getItemTotalAmount {
    if(productPrice==null)
    {
      return 0.0;
    }
    return productPrice!*quantity;
  }

  double get getFinalPriceAfterDiscount {
    return calculatePriceAfterDiscount(price: getItemTotalAmount - extraDiscount, discount: discount);
  }


  String get getGST {
    if(product==null)
    {
      return '';
    }
    if(productPrice==null)
    {
      return '';
    }
    String tax = '0';
    for (final x in product!.hsnTaxSlab) {
      if (x.priceFrom.isNotEmpty && x.priceTo.isNotEmpty) {
        final from = double.tryParse(x.priceFrom) ?? 0.0;
        final to = double.tryParse(x.priceTo) ?? 0.0;

        if (productPrice! >= from && productPrice!<= to) {
          tax = x.tax?? '0';
          break; // stop after first matching element
        }
      }
    }
    return tax;
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {


    var getProductId = json['productId']?.toString();
    ProductModel? getProduct;
    if (json['product'] != null) {
      getProduct = ProductModel.fromJson(
        Map<String, dynamic>.from(json['product']),
      );
    }

    final item = SaleItem(
      id: json['id']?.toString() ?? '',
      onChanged: () {},
      product: getProduct,
    );

    item.productPrice = double.tryParse(
      json['amount']?.toString() ?? '',
    );

    item._itemFinalPrice = double.tryParse(
      json['itemFinalPrice']?.toString() ?? '',
    ) ??
        0;

    item.mrpPercent = double.tryParse(
      json['mrpPercent']?.toString() ?? '',
    ) ??
        18.0;

    item.wholePercent = double.tryParse(
      json['wholePercent']?.toString() ?? '',
    ) ??
        8.0;

    item.retailPercent = double.tryParse(
      json['retailPercent']?.toString() ?? '',
    ) ??
        12.0;

    return item;
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product?.toJson(),
      'amount': productPrice,
      'itemFinalPrice': getFinalPriceAfterDiscount.toString(),
      'mrpPercent': mrpPercent,
      'wholePercent': wholePercent,
      'retailPercent': retailPercent,
    };
  }

  Map<String, String> toJsonApi() {
    return {
      'id': id,
      'amount': productPrice.toString(),
      'item_qty': product != null ? (product!.qty ?? '0') : '0',
      'size': product != null ? (product!.size?.id ?? '') : '',
      'color': product != null ? (product!.color?.id ?? '') : '',
      'hsn':product != null ? (product!.hsnCode?.id?? '') : '',
      'discount_per': product != null && product!.discount != null ? product!.discount!.toString() : '',
      'extra_discount': extraDiscount.toStringAsFixed(2),
      'extra_charge': extraCharge.toStringAsFixed(2),
      'itemFinalPrice': getFinalPriceAfterDiscount.toStringAsFixed(2),
      'gst': getGST.toString(),
    };
  }


  void dispose() {
    nameController.dispose();
    brandController.dispose();
    quantityController.dispose();
    priceController.dispose();
    discountController.dispose();
    productFocusNode.dispose();
  }
}