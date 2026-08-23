class TransportResponse {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<TransportModel> transportList;

  TransportResponse({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.transportList,
  });

  factory TransportResponse.fromJson(Map<String, dynamic> json) {
    return TransportResponse(
      code: json['code'] ?? 0,
      error: json['error'] ?? false,
      nums: json['nums']?.toString() ?? '',
      totalData: json['TotalData']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      transportList: (json['TransportList'] as List<dynamic>?)
          ?.map(
            (e) => TransportModel.fromJson(
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
      'TransportList': transportList
          .map((e) => e.toJson())
          .toList(),
    };
  }
}

class TransportModel {
  final String id;
  final String transport;
  final String owner;
  final String mobile;
  final String location;
  final String address;

  TransportModel({
    required this.id,
    required this.transport,
    required this.owner,
    required this.mobile,
    required this.location,
    required this.address,
  });

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      id: json['id']?.toString() ?? '',
      transport: json['transport']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      location: json['Location']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transport': transport,
      'owner': owner,
      'mobile': mobile,
      'Location': location,
      'address': address,
    };
  }
}