class StockDetailsModel {
  final String id;
  final String typesFor;
  final String storeId;
  final String barcodeId;
  final String stocks;
  final String addTime;
  final String billDate;
  final String challanId;
  final String barcode;
  final String challanNo;

  const StockDetailsModel({
    required this.id,
    required this.typesFor,
    required this.storeId,
    required this.barcodeId,
    required this.stocks,
    required this.addTime,
    required this.billDate,
    required this.challanId,
    required this.barcode,
    required this.challanNo,
  });

  factory StockDetailsModel.fromJson(Map<String, dynamic> json) {
    return StockDetailsModel(
      id: json['id']?.toString() ?? '',
      typesFor: json['Types_for']?.toString() ?? '',
      storeId: json['s_w_id']?.toString() ?? '',
      barcodeId: json['barcode_id']?.toString() ?? '',
      stocks: json['stocks']?.toString() ?? '0',
      addTime: json['add_time']?.toString() ?? '',
      billDate: json['bill_date']?.toString() ?? '',
      challanId: json['challan_id']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      challanNo: json['challan_no']?.toString() ?? '',
    );
  }
}
