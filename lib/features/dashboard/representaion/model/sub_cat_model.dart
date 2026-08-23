class SubCategoryResponse {
  final int code;
  final bool error;
  final String msg;
  final List<SubCategoryModel> subCategoryList;

  SubCategoryResponse({
    required this.code,
    required this.error,
    required this.msg,
    required this.subCategoryList,
  });

  factory SubCategoryResponse.fromJson(Map<String, dynamic> json) {
    return SubCategoryResponse(
      code: json['code'] ?? 0,
      error: json['error'] ?? false,
      msg: json['msg']?.toString() ?? '',
      subCategoryList: (json['SubCategoryList'] as List<dynamic>?)
          ?.map((e) => SubCategoryModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'msg': msg,
      'SubCategoryList':
      subCategoryList.map((e) => e.toJson()).toList(),
    };
  }
}

class SubCategoryModel {
  final String id;
  final String subcategory;

  SubCategoryModel({
    required this.id,
    required this.subcategory,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id']?.toString() ?? '',
      subcategory: json['subcategory']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subcategory': subcategory,
    };
  }
}