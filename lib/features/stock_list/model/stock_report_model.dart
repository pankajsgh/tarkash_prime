class StockListModel {
  final String barcodeId;
  final String barcode;
  final int totalStocks;
  final List<StockEntryModel> details;

  const StockListModel({
    required this.barcodeId,
    required this.barcode,
    required this.totalStocks,
    required this.details,
  });

  factory StockListModel.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['details'];

    return StockListModel(
      barcodeId: json['barcode_id']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      totalStocks: _toInt(json['total_stocks']),
      details: rawDetails is List
          ? rawDetails
          .whereType<Map>()
          .map(
            (item) => StockEntryModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : [],
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class StockEntryModel {
  final String id;
  final String billDate;
  final String challanNo;
  final String challanId;
  final String storeId;
  final int stocks;
  final String addTime;
  final String typesFor;

  const StockEntryModel({
    required this.id,
    required this.billDate,
    required this.challanNo,
    required this.challanId,
    required this.storeId,
    required this.stocks,
    required this.addTime,
    required this.typesFor,
  });

  factory StockEntryModel.fromJson(Map<String, dynamic> json) {
    return StockEntryModel(
      id: json['id']?.toString() ?? '',
      billDate: json['bill_date']?.toString() ?? '',
      challanNo: json['challan_no']?.toString() ?? '',
      challanId: json['challan_id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ??
          json['s_w_id']?.toString() ??
          '',
      stocks: int.tryParse(
        json['stocks']?.toString() ?? '',
      ) ??
          0,
      addTime: json['add_time']?.toString() ?? '',
      typesFor: json['Types_for']?.toString() ?? '',
    );
  }
}
