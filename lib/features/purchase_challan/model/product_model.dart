
import '../../../core/extensions/map_ext.dart';
import 'color_model.dart';
import 'hsn_model.dart';
import 'size_model.dart';


class ProductListModel {
  final int? code;
  final bool? error;
  final String? nums;
  final String? totalData;
  final String? msg;
  final List<ProductModelItem> productList;

  ProductListModel({
    this.code,
    this.error,
    this.nums,
    this.totalData,
    this.msg,
    this.productList = const [],
  });

  factory ProductListModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProductListModel(
      code: int.tryParse(
        json['code']?.toString() ?? '',
      ),

      error: json['error'] is bool
          ? json['error'] as bool
          : json['error']?.toString().toLowerCase() == 'true',

      nums: json['nums']?.toString(),

      totalData: json['TotalData']?.toString(),

      msg: json['msg']?.toString(),

      productList: json['ProductList'] is List
          ? (json['ProductList'] as List)
          .whereType<Map>()
          .map(
            (e) => ProductModelItem.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : [],
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


// ============================================================
// PRODUCT MODEL
// ============================================================

class ProductModelItem {
  final String? id;
  final String name;

  final String? supplierId;
  final String? supplierName;
  final String? supplierProductName;

  final String? category;
  final String? categoryId;
  final String? subCategory;

  final HsnCodeModel? hsnCode;
  final BrandModel? brand;

  final List<HsnTaxSlab> hsnTaxSlab;

  final String? createdAt;
  final String? updatedAt;

  ProductModelItem({
    this.id,
    required this.name,
    this.supplierId,
    this.supplierName,
    this.supplierProductName,
    this.category,
    this.categoryId,
    this.subCategory,
    this.hsnCode,
    this.brand,
    this.hsnTaxSlab = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModelItem.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProductModelItem(

      // --------------------------------------------------------
      // BASIC
      // --------------------------------------------------------

      id: json['id']?.toString(),

      name: json['product']?.toString() ?? '',


      // --------------------------------------------------------
      // SUPPLIER
      // --------------------------------------------------------

      supplierId:
      json['supl_id']?.toString(),

      supplierName:
      json['supplier_name']?.toString(),

      supplierProductName:
      json['supllier_prod_name']?.toString(),


      // --------------------------------------------------------
      // CATEGORY
      // --------------------------------------------------------

      category:
      json['category']?.toString(),
      categoryId:
      json['category_id']?.toString(),

      // --------------------------------------------------------
      // SUB CATEGORY
      // --------------------------------------------------------

      subCategory:
      json['sub_category']?.toString(),


      // --------------------------------------------------------
      // HSN
      // --------------------------------------------------------

      hsnCode: json['hsncode'] is Map
          ? HsnCodeModel.fromJson(
        Map<String, dynamic>.from(
          json['hsncode'] as Map,
        ),
      )
          : null,


      // --------------------------------------------------------
      // BRAND
      // --------------------------------------------------------

      brand: json['brand'] is Map
          ? BrandModel.fromJson(
        Map<String, dynamic>.from(
          json['brand'] as Map,
        ),
      )
          : null,


      // --------------------------------------------------------
      // HSN TAX SLAB
      // --------------------------------------------------------

      hsnTaxSlab:
      json['HSNTaxSlab'] is List
          ? (json['HSNTaxSlab'] as List)
          .whereType<Map>()
          .map(
            (e) => HsnTaxSlab.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : [],


      // --------------------------------------------------------
      // DATE
      // --------------------------------------------------------

      createdAt:
      json['created_at']?.toString(),

      updatedAt:
      json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'product': name,

      'supl_id': supplierId,

      'supplier_name': supplierName,

      'supllier_prod_name':
      supplierProductName,

      'category': category,

      'sub_category': subCategory,

      'hsncode':
      hsnCode?.toJson(),

      'brand':
      brand?.toJson(),

      'HSNTaxSlab': hsnTaxSlab
          .map((e) => e.toJson())
          .toList(),

      'created_at': createdAt,

      'updated_at': updatedAt,
    };
  }
}

// =========================================================
// PRODUCT LIST RESPONSE
// =========================================================

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
      code: int.tryParse(
        json['code']?.toString() ?? '',
      ),

      error: json['error'] is bool
          ? json['error'] as bool
          : json['error']?.toString().toLowerCase() == 'true',

      nums: json['nums']?.toString(),

      totalData: json['TotalData']?.toString(),

      msg: json['msg']?.toString(),

      // productList: json['ProductList'] is List
      //     ? (json['ProductList'] as List)
      //     .whereType<Map>()
      //     .map(
      //       (e) => ProductModel.fromJson(
      //     Map<String, dynamic>.from(e),
      //   ),
      // )
      //     .toList()
      //     : [],

      productList: json.containsKey('ProductList')
          ?json.getList('ProductList', ProductModel.fromJson)
          :json.getList('data', ProductModel.fromJson),
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

  ColorModel? color;
  SizeModel? size;

  String? supplierName;
  String? category;
  String? categoryId;

  HsnCodeModel? hsnCode;
  BrandModel? brand;

  List<HsnTaxSlab> hsnTaxSlab;

  String? qty;
  String? purchaseRate;
  String? discount;
  String? barcode;
  String? b2bPrice;
  String? b2cPrice;
  String? mrp;

  ProductModel({
    this.id,
    required this.name,
    this.color,
    this.size,
    this.supplierName,
    this.category,
    this.categoryId,
    this.hsnCode,
    this.brand,
    this.hsnTaxSlab = const [],
    this.qty,
    this.purchaseRate,
    this.discount,
    this.barcode,
    this.b2bPrice,
    this.b2cPrice,
    this.mrp,
  });

  factory ProductModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProductModel(
      // ---------------------------------------------------
      // BASIC
      // ---------------------------------------------------

      id: json['id']?.toString(),

      name: json['product']?.toString() ?? '',

      supplierName: json['supl_name']?.toString(),

      category: json['category']?.toString(),
      categoryId: json['category_id']?.toString(),
      barcode: json['barcode']?.toString(),

      // ---------------------------------------------------
      // SIZE
      // ---------------------------------------------------

      size: json['size'] is Map
          ? SizeModel.fromJson(
        Map<String, dynamic>.from(
          json['size'] as Map,
        ),
      )
          : null,

      // ---------------------------------------------------
      // COLOR
      // ---------------------------------------------------

      color: json['color'] is Map
          ? ColorModel.fromJson(
        Map<String, dynamic>.from(
          json['color'] as Map,
        ),
      )
          : null,

      // ---------------------------------------------------
      // HSN
      // ---------------------------------------------------

      hsnCode: json['hsncode'] is Map
          ? HsnCodeModel.fromJson(
        Map<String, dynamic>.from(
          json['hsncode'] as Map,
        ),
      )
          : null,

      // ---------------------------------------------------
      // BRAND
      // ---------------------------------------------------

      brand: json['brand'] is Map
          ? BrandModel.fromJson(
        Map<String, dynamic>.from(
          json['brand'] as Map,
        ),
      )
          : null,

      // ---------------------------------------------------
      // HSN TAX SLAB
      // ---------------------------------------------------

      hsnTaxSlab: json['HSNTaxSlab'] is List
          ? (json['HSNTaxSlab'] as List)
          .whereType<Map>()
          .map(
            (e) => HsnTaxSlab.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : [],

      qty: json['qty']?.toString(),

      purchaseRate: json['purchaseRate']?.toString(),

      discount: json['discount']?.toString(),

      b2bPrice: json.getString('b2b_price'),
      b2cPrice: json.getString('b2c_price'),
      mrp: json.getString('mrp'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'product': name,

      'supl_name': supplierName,

      'category': category,

      'categoryId': categoryId,

      'size': size?.toJson(),

      'color': color?.toJson(),

      'hsncode': hsnCode?.toJson(),

      'barcode': barcode,

      'brand': brand?.toJson(),

      'HSNTaxSlab': hsnTaxSlab
          .map((e) => e.toJson())
          .toList(),

      'qty': qty,

      'purchaseRate': purchaseRate,

      'discount': discount,

      'b2b_price': b2bPrice,

      'b2c_price': b2cPrice,

      'mrp': mrp,
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

  factory HsnCodeModel.fromJson(
      Map<String, dynamic> json,
      ) {
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

  factory BrandModel.fromJson(
      Map<String, dynamic> json,
      ) {
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
