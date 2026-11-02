class CityListResponse {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<CityModelItem> cityList;

  CityListResponse({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.cityList,
  });

  factory CityListResponse.fromJson(Map<String, dynamic> json) {
    return CityListResponse(
      code: int.tryParse(json['code']?.toString() ?? '') ?? 0,
      error: json['error'] == true ||
          json['error']?.toString() == 'true',
      nums: json['nums']?.toString() ?? '0',
      totalData: json['TotalData']?.toString() ?? '0',
      msg: json['msg']?.toString() ?? '',
      cityList: (json['CityList'] as List? ?? [])
          .map(
            (item) => CityModelItem.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
    );
  }
}

class CityModelItem {
  final String id;
  final String stateId;
  final String cityName;

  CityModelItem({
    required this.id,
    required this.stateId,
    required this.cityName,
  });

  factory CityModelItem.fromJson(Map<String, dynamic> json) {
    return CityModelItem(
      id: json['id']?.toString() ?? '',
      stateId: json['state_id']?.toString() ?? '',
      cityName: json['city_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state_id': stateId,
      'city_name': cityName,
    };
  }
}