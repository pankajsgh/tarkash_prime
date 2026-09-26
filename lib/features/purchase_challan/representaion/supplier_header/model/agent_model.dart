import 'package:calculation_panel/features/purchase_challan/representaion/supplier_header/model/supplier_model.dart';

class AgentResponseModel {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<Agency> agentList;

  AgentResponseModel({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.agentList,
  });

  factory AgentResponseModel.fromJson(Map<String, dynamic> json) {
    return AgentResponseModel(
      code: int.tryParse(json['code']?.toString() ?? '0') ?? 0,
      error: json['error'] == true,
      nums: json['nums']?.toString() ?? '0',
      totalData: json['TotalData']?.toString() ?? '0',
      msg: json['msg']?.toString() ?? '',
      agentList: (json['AgentList'] as List?)
          ?.map(
            (item) => Agency.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList() ??
          [],
    );
  }
}

