class StateListModel {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<StateModelItem> stateList;

  StateListModel({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.stateList,
  });

  factory StateListModel.fromJson(Map<String, dynamic> json) {
    return StateListModel(
      code: int.tryParse(json['code']?.toString() ?? '') ?? 0,
      error: json['error'] == true ||
          json['error']?.toString() == 'true',
      nums: json['nums']?.toString() ?? '0',
      totalData: json['TotalData']?.toString() ?? '0',
      msg: json['msg']?.toString() ?? '',
      stateList: (json['StateListList'] as List? ?? [])
          .map(
            (item) => StateModelItem.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'nums': nums,
      'TotalData': totalData,
      'msg': msg,
      'StateListList': stateList.map((item) => item.toJson()).toList(),
    };
  }
}

class StateModelItem {
  final String id;
  final String stateName;
  final String stateCode;

  StateModelItem({
    required this.id,
    required this.stateName,
    required this.stateCode,
  });

  factory StateModelItem.fromJson(Map<String, dynamic> json) {
    return StateModelItem(
      id: json['id']?.toString() ?? '',
      stateName: json['state_name']?.toString() ?? '',
      stateCode: json['state_code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state_name': stateName,
      'state_code': stateCode,
    };
  }

  @override
  String toString() => stateName;
}