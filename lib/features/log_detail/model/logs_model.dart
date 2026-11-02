

class LogResponseModel {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<LogModel> logs;

  const LogResponseModel({
    this.code = 0,
    this.error = false,
    this.nums = '0',
    this.totalData = '0',
    this.msg = '',
    this.logs = const [],
  });

  factory LogResponseModel.fromJson(Map<String, dynamic> json) {
    final rawLogs = json['LogsList'] ?? json['logs'] ?? json['data'];

    return LogResponseModel(
      code: int.tryParse(json['code']?.toString() ?? '') ?? 0,
      error: json['error'] == true ||
          json['error']?.toString().toLowerCase() == 'true' ||
          json['error']?.toString() == '1',
      nums: json['nums']?.toString() ?? '0',
      totalData: json['TotalData']?.toString() ?? '0',
      msg: json['msg']?.toString() ??
          json['message']?.toString() ??
          '',
      logs: rawLogs is List
          ? rawLogs
          .whereType<Map>()
          .map((item) => LogModel.fromJson(
        Map<String, dynamic>.from(item),
      ))
          .toList()
          : const [],
    );
  }
}

class LogModel {
  final String id;
  final String invId;
  final String type;
  final String action;
  final String uid;
  final String oldData;
  final String newData;
  final String description;
  final String createdAt;
  final Map<String, dynamic> raw;

  const LogModel({
    this.id = '',
    this.invId = '',
    this.type = '',
    this.action = '',
    this.uid = '',
    this.oldData = '',
    this.newData = '',
    this.description = '',
    this.createdAt = '',
    this.raw = const {},
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id']?.toString() ?? '',
      invId: json['inv_id']?.toString() ?? '',
      type: json['atypes']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      uid: json['uid']?.toString() ?? '',
      oldData: json['old_data']?.toString() ?? '',
      newData: json['new_data']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ??
          json['add_time']?.toString() ??
          json['createdAt']?.toString() ??
          '',
      raw: Map<String, dynamic>.from(json),
    );
  }
}