import 'package:calculation_panel/features/dashboard/representaion/model/hsn_model.dart';

class ProductListResponse {
  final int? code;
  final bool? error;
  final String? nums;
  final String? totalData;
  final String? msg;
  final List<ProductModel> productList;

  ProductListResponse({
    this.code,
    this.error,
    this.nums,
    this.totalData,
    this.msg,
    this.productList = const [],
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      code: int.tryParse(json['code']?.toString() ?? ''),
      error: json['error'] is bool
          ? json['error']
          : json['error']?.toString().toLowerCase() == 'true',
      nums: json['nums']?.toString(),
      totalData: json['TotalData']?.toString(),
      msg: json['msg']?.toString(),

      productList: (json['ProductList'] as List?)
          ?.map(
            (e) => ProductModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'nums': nums,
      'TotalData': totalData,
      'msg': msg,
      'ProductList': productList
          .map((e) => e.toJson())
          .toList(),
    };
  }
}

// =========================================================
// PRODUCT
// =========================================================

class ProductModel {
  final String? id;
  String name;
  String? supplierName;
  String? category;
  HsnCodeModel? hsnCode;
  BrandModel? brand;
  List<HsnTaxSlab> hsnTaxSlab;

  ProductModel({
    this.id,
    required this.name,
    this.supplierName,
    this.category,
    this.hsnCode,
    this.brand,
    this.hsnTaxSlab = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      name: json['product']?? "",
      supplierName: json['supl_name']?.toString(),
      category: json['category']?.toString(),

      hsnCode: json['hsncode'] is Map
          ? HsnCodeModel.fromJson(
        Map<String, dynamic>.from(json['hsncode']),
      )
          : null,

      brand: json['brand'] is Map
          ? BrandModel.fromJson(
        Map<String, dynamic>.from(json['brand']),
      )
          : null,

      hsnTaxSlab: (json['HSNTaxSlab'] as List?)
          ?.map(
            (e) => HsnTaxSlab.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': name,
      'supl_name': supplierName,
      'category': category,
      'hsncode': hsnCode?.toJson(),
      'brand': brand?.toJson(),
      'HSNTaxSlab': hsnTaxSlab
          .map((e) => e.toJson())
          .toList(),
    };
  }
}

// =========================================================
// HSN CODE
// =========================================================

class HsnCodeModel {
  final String? id;
  final String? name;

  HsnCodeModel({
    this.id,
    this.name,
  });

  factory HsnCodeModel.fromJson(Map<String, dynamic> json) {
    return HsnCodeModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// =========================================================
// BRAND
// =========================================================

class BrandModel {
  final String? id;
  final String? name;

  BrandModel({
    this.id,
    this.name,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// =========================================================
// HSN TAX SLAB
// =========================================================

// class HsnTaxSlabModel {
//   final String? priceFrom;
//   final String? priceTo;
//   final String? tax;
//
//   HsnTaxSlabModel({
//     this.priceFrom,
//     this.priceTo,
//     this.tax,
//   });
//
//   factory HsnTaxSlabModel.fromJson(Map<String, dynamic> json) {
//     return HsnTaxSlabModel(
//       priceFrom: json['PriceFrom']?.toString(),
//       priceTo: json['PriceTo']?.toString(),
//       tax: json['Tax']?.toString(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'PriceFrom': priceFrom,
//       'PriceTo': priceTo,
//       'Tax': tax,
//     };
//   }
//}