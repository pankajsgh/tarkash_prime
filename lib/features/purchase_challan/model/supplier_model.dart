//
// class PartyModel {
//   final int code;
//   final bool error;
//   final String nums;
//   final String totalData;
//   final String msg;
//   final List<Party> partyList;
//   final List<CategoryMargin> categoryMargins;
//
//   PartyModel({
//     required this.code,
//     required this.error,
//     required this.nums,
//     required this.totalData,
//     required this.msg,
//     required this.partyList,
//     this.categoryMargins = const [],
//   });
//
//   factory PartyModel.fromJson(Map<String, dynamic> json) {
//     return PartyModel(
//       code: int.tryParse(json['code']?.toString() ?? '') ?? 0,
//       error: json['error'] == true ||
//           json['error']?.toString() == 'true' ||
//           json['error']?.toString() == '1',
//       nums: json['nums']?.toString() ?? '',
//       totalData: json['TotalData']?.toString() ?? '',
//       msg: json['msg']?.toString() ?? '',
//       partyList: (json['PartyList'] as List?)
//           ?.map((e) => Party.fromJson(
//         Map<String, dynamic>.from(e as Map),
//       ))
//           .toList() ??
//           [],
//       categoryMargins: (json['CategoryMargins'] as List?)
//           ?.map((e) => CategoryMargin.fromJson(
//         Map<String, dynamic>.from(e as Map),
//       ))
//           .toList() ??
//           [],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'code': code,
//       'error': error,
//       'nums': nums,
//       'TotalData': totalData,
//       'msg': msg,
//       'PartyList': partyList.map((e) => e.toJson()).toList(),
//       'CategoryMargins': categoryMargins.map((e) => e.toJson()).toList(),
//     };
//   }
// }
