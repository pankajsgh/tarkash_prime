
import '../../../core/extensions/map_ext.dart';

class ModelVoucherConfigurationList {
  final int code;
  final bool error;
  final String msg;
  final String totalData;
  final List<VoucherType> data;

  ModelVoucherConfigurationList({
    required this.code,
    required this.error,
    required this.msg,
    required this.totalData,
    required this.data,
  });

  factory ModelVoucherConfigurationList.fromJson(Map<String, dynamic> json) {
    return ModelVoucherConfigurationList(
      code: json["code"],
      error: json["error"],
      msg: json.getString("msg"),
      totalData: json.getString("total_data"),
      data: json.getList("data", VoucherType.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "error": error,
      "msg": msg,
      "total_data": totalData,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

class VoucherType {
  final String id;
  final String name;
  final List<VoucherSeries> series;

  VoucherType({
    required this.id,
    required this.name,
    required this.series,
  });

  factory VoucherType.fromJson(Map<String, dynamic> json) {
    return VoucherType(
      id: json.getString("id"),
      name: json.getString("name"),
      series: json.getList("series", VoucherSeries.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "series": series.map((e) => e.toJson()).toList(),
    };
  }
}

class VoucherSeries {
  final String id;
  final String name;
  final String store;
  final String invoiceFormate;

  VoucherSeries({
    required this.id,
    required this.name,
    required this.store,
    required this.invoiceFormate,
  });

  factory VoucherSeries.fromJson(Map<String, dynamic> json) {
    return VoucherSeries(
      id: json.getString("id"),
      name: json.getString("name"),
      store: json.getString("store"),
      invoiceFormate: json.getString("invoice_formate"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "store": store,
      "invoice_formate": invoiceFormate,
    };
  }
}