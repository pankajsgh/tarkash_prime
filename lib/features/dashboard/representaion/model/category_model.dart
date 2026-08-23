class CategoryResponse {
  final int code;
  final bool error;
  final String msg;
  final List<CategoryModel> categoryList;

  CategoryResponse({
    required this.code,
    required this.error,
    required this.msg,
    required this.categoryList,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      code: json['code'] ?? 0,
      error: json['error'] ?? false,
      msg: json['msg']?.toString() ?? '',
      categoryList: (json['CategoryList'] as List<dynamic>?)
          ?.map((e) => CategoryModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'msg': msg,
      'CategoryList': categoryList.map((e) => e.toJson()).toList(),
    };
  }
}

class CategoryModel {
  final String id;
  final String category;

  CategoryModel({
    required this.id,
    required this.category,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
    };
  }
}