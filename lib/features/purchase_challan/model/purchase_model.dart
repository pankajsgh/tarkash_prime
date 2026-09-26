
import 'package:flutter/material.dart';

import '../../../core/ulitls/calculation.dart';
import 'product_model.dart';

class PurchaseItem {
  final String id;
  String? productId;
  ProductModel? product;
  FocusNode articleFocusNode = FocusNode();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController mrpRateController = TextEditingController();
  final TextEditingController wholesaleRateController = TextEditingController();
  final TextEditingController retailRateController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final FocusNode productFocusNode = FocusNode();

  PurchaseItem({
    required this.id, required void Function() onChanged,
    this.product,
    this.productId,
  }){
    if(product!=null)
      {
        nameController.text = product!.name;
        brandController.text = product!.brand!=null? product!.brand!.name?? '':'';
        quantityController.text = product!.qty?? '';
        priceController.text = product!.purchaseRate?? '';
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

  void setDiscountedAmount(){
    setMrpAmount();
    setWholesaleAmount();
    setRetailAmount();

    productPrice = textToDouble(priceController.text);

    if(product!=null)
    {
      product!.qty =quantityController.text;
      product!.purchaseRate=priceController.text;
      product!.discount = discountController.text;
    }
  }

  void setMrpAmount(){
    mrpRateController.text = calculatePriceAfterText(price: textToDouble(priceController.text), discount: mrpPercent).toString();
  }

  void setWholesaleAmount(){
    wholesaleRateController.text = calculatePriceAfterText(price: textToDouble(priceController.text), discount: wholePercent).toString();
  }

  void setRetailAmount(){
    retailRateController.text = calculatePriceAfterText(price: textToDouble(priceController.text), discount: retailPercent).toString();
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

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {


    var getProductId = json['productId']?.toString();
    ProductModel? getProduct;
    if (json['product'] != null) {
      getProduct = ProductModel.fromJson(
        Map<String, dynamic>.from(json['product']),
      );
    }

    final item = PurchaseItem(
        id: json['id']?.toString() ?? '',
        onChanged: () {},
        productId: getProductId,
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
      'productId': productId?? '',
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
      'productId': productId ?? '',
      'amount': productPrice.toString(),
      'item_qty': product != null ? (product!.qty ?? '0') : '0',
      'size': product != null ? (product!.size?.id ?? '') : '',
      'color': product != null ? (product!.color?.id ?? '') : '',
      'hsn':product != null ? (product!.hsnCode?.id?? '') : '',
      'discount_per': product != null && product!.discount != null ? product!.discount!.toString() : '',
      'extra_discount': extraDiscount.toString(),
      'extra_charge': extraCharge.toString(),
      'itemFinalPrice': getFinalPriceAfterDiscount.toString(),
      'gst': getGST.toString(),
    };
  }


  void dispose() {
    nameController.dispose();
    brandController.dispose();
    quantityController.dispose();
    priceController.dispose();
    mrpRateController.dispose();
    wholesaleRateController.dispose();
    retailRateController.dispose();
    discountController.dispose();
    productFocusNode.dispose();
  }
}