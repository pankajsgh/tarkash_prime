class HsnResponse {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<HsnModel> hsnList;

  HsnResponse({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.hsnList,
  });

  factory HsnResponse.fromJson(Map<String, dynamic> json) {
    return HsnResponse(
      code: json['code'] ?? 0,
      error: json['error'] ?? false,
      nums: json['nums']?.toString() ?? '',
      totalData: json['TotalData']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      hsnList: (json['HSNList'] as List<dynamic>?)
          ?.map((e) => HsnModel.fromJson(e))
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
      'HSNList': hsnList.map((e) => e.toJson()).toList(),
    };
  }
}


class HsnTaxSlab {
  final String priceFrom;
  final String priceTo;
  final String tax;

  HsnTaxSlab({
    required this.priceFrom,
    required this.priceTo,
    required this.tax,
  });

  factory HsnTaxSlab.fromJson(Map<String, dynamic> json) {
    return HsnTaxSlab(
      priceFrom: json['PriceFrom']?.toString() ?? '',
      priceTo: json['PriceTo']?.toString() ?? '',
      tax: json['Tax']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PriceFrom': priceFrom,
      'PriceTo': priceTo,
      'Tax': tax,
    };
  }
}

class HsnModel {
  final String id;
  final String hsnCode;
  final List<HsnTaxSlab> hsnTaxSlab;

  HsnModel({
    required this.id,
    required this.hsnCode,
    required this.hsnTaxSlab,
  });

  factory HsnModel.fromJson(Map<String, dynamic> json) {
    return HsnModel(
      id: json['id']?.toString() ?? '',
      hsnCode: json['hsncode']?.toString().trim() ?? '',
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
      'hsncode': hsnCode,
      'HSNTaxSlab': hsnTaxSlab
          .map((e) => e.toJson())
          .toList(),
    };
  }
}