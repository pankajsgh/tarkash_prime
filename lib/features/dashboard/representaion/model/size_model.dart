class SizeResponse {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<SizeModel> sizeList;

  SizeResponse({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.sizeList,
  });

  factory SizeResponse.fromJson(Map<String, dynamic> json) {
    return SizeResponse(
      code: json['code'] ?? 0,
      error: json['error'] ?? false,
      nums: json['nums']?.toString() ?? '',
      totalData: json['TotalData']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      sizeList: (json['SizeList'] as List<dynamic>?)
          ?.map((e) => SizeModel.fromJson(e))
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
      'SizeList': sizeList.map((e) => e.toJson()).toList(),
    };
  }
}

class SizeModel {
  final String id;
  final String sizeName;

  SizeModel({
    required this.id,
    required this.sizeName,
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      id: json['id']?.toString() ?? '',
      sizeName: json['size_name']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size_name': sizeName,
    };
  }
}