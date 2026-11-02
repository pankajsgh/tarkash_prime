
class ProductParameterModel {
  final String id;
  final String productId;
  final String productName;
  final String hsnId;
  final String hsnName;
  final String sizeId;
  final String sizeName;
  final String colorId;
  final String colorName;
  final String barcode;
  final String purchasePrice;
  final String b2bPrice;
  final String b2cPrice;
  final String mrp;
  final String status;
  final String createdAt;
  final String updatedAt;

  ProductParameterModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.hsnId,
    required this.hsnName,
    required this.sizeId,
    required this.sizeName,
    required this.colorId,
    required this.colorName,
    required this.barcode,
    required this.purchasePrice,
    required this.b2bPrice,
    required this.b2cPrice,
    required this.mrp,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductParameterModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final product = json['product'] is Map
        ? Map<String, dynamic>.from(json['product'])
        : <String, dynamic>{};

    final hsn = json['hsn'] is Map
        ? Map<String, dynamic>.from(json['hsn'])
        : <String, dynamic>{};

    final size = json['size'] is Map
        ? Map<String, dynamic>.from(json['size'])
        : <String, dynamic>{};

    final color = json['color'] is Map
        ? Map<String, dynamic>.from(json['color'])
        : <String, dynamic>{};

    return ProductParameterModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: product['name']?.toString() ??
          json['product_name']?.toString() ??
          (json['product'] is String ? json['product'] : '') ??
          '',
      hsnId: hsn['id']?.toString() ??
          json['hsn_id']?.toString() ??
          '',
      hsnName: hsn['name']?.toString() ??
          json['hsn_name']?.toString() ??
          '',
      sizeId: size['id']?.toString() ??
          json['size_id']?.toString() ??
          '',
      sizeName: size['name']?.toString() ??
          json['size_name']?.toString() ??
          '',
      colorId: color['id']?.toString() ??
          json['color_id']?.toString() ??
          '',
      colorName: color['name']?.toString() ??
          json['color_name']?.toString() ??
          '',
      barcode: json['barcode']?.toString() ?? '',
      purchasePrice:
      json['purchase_price']?.toString() ?? '0.00',
      b2bPrice: json['b2b_price']?.toString() ?? '0.00',
      b2cPrice: json['b2c_price']?.toString() ?? '0.00',
      mrp: json['mrp']?.toString() ?? '0.00',
      status: json['status']?.toString() ?? '0',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  ProductParameterModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? hsnId,
    String? hsnName,
    String? sizeId,
    String? sizeName,
    String? colorId,
    String? colorName,
    String? barcode,
    String? purchasePrice,
    String? b2bPrice,
    String? b2cPrice,
    String? mrp,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProductParameterModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      hsnId: hsnId ?? this.hsnId,
      hsnName: hsnName ?? this.hsnName,
      sizeId: sizeId ?? this.sizeId,
      sizeName: sizeName ?? this.sizeName,
      colorId: colorId ?? this.colorId,
      colorName: colorName ?? this.colorName,
      barcode: barcode ?? this.barcode,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      b2bPrice: b2bPrice ?? this.b2bPrice,
      b2cPrice: b2cPrice ?? this.b2cPrice,
      mrp: mrp ?? this.mrp,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
