
import 'package:calculation_panel/core/vars/global_vars.dart';
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
    this.extraDiscount = 0,
    this.extraCharge = 0,
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
  double mrpPercent = 0.0;
  double wholePercent = 0.0;
  double retailPercent = 0.0;

  void setDiscountedAmount(){
    if(GlobalVars.supplierCatMargin.isNotEmpty)
   {
     for(var x in GlobalVars.supplierCatMargin) {
       if(product!.categoryId == x.categoryId)
         {
           mrpPercent = double.tryParse(x.mrp)?? 0.0;
           wholePercent = double.tryParse(x.wholesale)?? 0.0;
           retailPercent = double.tryParse(x.retail)?? 0.0;
         }
     }
   }

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

  Map<String, String>? getBarcodeParm (){
    if(product!=null && product!.size!=null && product!.color!=null && productPrice!=null && productPrice!>0)
    {
      Map<String, String> parms = {
        'size_id': product!.size!.id?? '',
        'color_id': product!.color!.id?? '',
        'purchase_price': productPrice.toString(),
        'b2b_price': calculatePriceAfterText(price: textToDouble(priceController.text), discount: wholePercent).toString(),
        'b2c_price': calculatePriceAfterText(price: textToDouble(priceController.text), discount: retailPercent).toString(),
        'mrp': calculatePriceAfterText(price: textToDouble(priceController.text), discount: mrpPercent).toString(),
        'status': '1',
      };
      return parms;
    }

    null;
    return null;
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
    ) ?? 0.0;

    item.wholePercent = double.tryParse(
      json['wholePercent']?.toString() ?? '',
    ) ??
        0.0;

    item.retailPercent = double.tryParse(
      json['retailPercent']?.toString() ?? '',
    ) ?? 0.0;

    // item.mrpRateController.text = calculatePriceAfterText(price: textToDouble(item.priceController.text), discount:item.mrpPercent).toString();
    //
    // item.wholesaleRateController.text = calculatePriceAfterText(price: textToDouble(item.priceController.text), discount: item.wholePercent).toString();
    //
    // item.retailRateController.text = calculatePriceAfterText(price: textToDouble(item.priceController.text), discount: item.retailPercent).toString();

    if(item.product!=null)
    {
      item.mrpRateController.text = item.product!.mrp.toString();
      item.wholesaleRateController.text = item.product!.b2bPrice.toString();
      item.retailRateController.text = item.product!.b2cPrice.toString();
    }

    return item;
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {

    if(product!=null)
      {
        product!.mrp = mrpRateController.text.trim();
        product!.b2bPrice =wholesaleRateController.text.trim();
        product!.b2cPrice =retailRateController.text.trim();
      }

    return {
      'id': id,
      'productId': productId?? '',
      'product': product?.toJson(),
      'amount': productPrice,
      'mrp': mrpRateController.text.trim(),
      'b2b_price': wholesaleRateController.text.trim(),
      'b2c_price':retailRateController.text.trim(),
      'itemFinalPrice': getFinalPriceAfterDiscount.toString(),
      'mrpPercent': mrpPercent,
      'hsn':product != null ? (product!.barcode?? '') : '',
      'wholePercent': wholePercent,
      'retailPercent': retailPercent,
    };
  }

  Map<String, String> toJsonApi() {
    return {
      'id': id,
      'productId': productId ?? '',
      'amount': productPrice.toString(),
      'mrp': mrpRateController.text.trim(),
      'b2b': wholesaleRateController.text.trim(),
      'b2c':retailRateController.text.trim(),
      'item_qty': product != null ? (product!.qty ?? '0') : '0',
      'size': product != null ? (product!.size?.id ?? '') : '',
      'color': product != null ? (product!.color?.id ?? '') : '',
      'hsn':product != null ? (product!.hsnCode?.id?? '') : '',
      'barcode': product != null ? (product!.barcode?? '') : '',
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
    mrpRateController.dispose();
    wholesaleRateController.dispose();
    retailRateController.dispose();
    discountController.dispose();
    productFocusNode.dispose();
  }
}