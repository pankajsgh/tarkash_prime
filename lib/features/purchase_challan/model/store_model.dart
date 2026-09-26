class StoreListResponse {
  final int? code;
  final bool? error;
  final String? nums;
  final String? totalData;
  final String? msg;
  final List<StoreModel> storeList;

  StoreListResponse({
    this.code,
    this.error,
    this.nums,
    this.totalData,
    this.msg,
    this.storeList = const [],
  });

  factory StoreListResponse.fromJson(Map<String, dynamic> json) {
    return StoreListResponse(
      code: json['code'] is int
          ? json['code']
          : int.tryParse(json['code']?.toString() ?? ''),
      error: json['error'] is bool
          ? json['error']
          : json['error']?.toString().toLowerCase() == 'true',
      nums: json['nums']?.toString(),
      totalData: json['TotalData']?.toString(),
      msg: json['msg']?.toString(),

      storeList: (json['StoreList'] as List?)
          ?.map(
            (e) => StoreModel.fromJson(
          e as Map<String, dynamic>,
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
      'StoreList': storeList
          .map((e) => e.toJson())
          .toList(),
    };
  }
}

class StoreModel {
  final String? id;
  final String? store;
  final String? shortName;

  StoreModel({
    this.id,
    this.store,
    this.shortName,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id']?.toString(),
      store: json['Store']?.toString(),
      shortName: json['ShortName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Store': store,
      'ShortName': shortName,
    };
  }
}