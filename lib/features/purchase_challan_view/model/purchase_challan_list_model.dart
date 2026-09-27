class PurchaseChallanListModel {
  final String id;
  final String supplierId;
  final String gstNo;

  final String storeId;
  String storeName;

  final String challanNo;
  final String challanDate;

  final String lrNo;
  final String lrDate;

  final String transportId;
  String transportName;

  final String agentId;
  String agentName;

  final int itemCount;

  final double valueOfGood;
  final double additionalDiscountTotal;
  final double additionalChargeValue;
  final double finalDiscount;
  final double taxableAmount;

  final double sgst;
  final double cgst;
  final double igst;

  final double grandTotal;

  final String remark;
  final String createdAt;
  final String updatedAt;

  PurchaseChallanListModel({
    required this.id,
    required this.supplierId,
    required this.gstNo,

    required this.storeId,
    required this.storeName,

    required this.challanNo,
    required this.challanDate,

    required this.lrNo,
    required this.lrDate,

    required this.transportId,
    required this.transportName,

    required this.agentId,
    required this.agentName,

    required this.valueOfGood,
    required this.additionalDiscountTotal,
    required this.additionalChargeValue,
    required this.finalDiscount,
    required this.taxableAmount,

    required this.sgst,
    required this.cgst,
    required this.igst,

    required this.grandTotal,

    required this.remark,
    required this.createdAt,
    required this.updatedAt,

    required this.itemCount,
  });

  factory PurchaseChallanListModel.fromJson(
      Map<String, dynamic> json,
      ) {
    double parseDouble(dynamic value) {
      return double.tryParse(
        value?.toString() ?? '',
      ) ??
          0.0;
    }

    return PurchaseChallanListModel(
      // ------------------------------------------------------
      // BASIC
      // ------------------------------------------------------

      id: json['id']?.toString() ?? '',

      supplierId:
      json['supplier_id']?.toString() ?? '',

      gstNo:
      json['gst_no']?.toString() ?? '',


      // ------------------------------------------------------
      // STORE
      // ------------------------------------------------------

      storeId:
      json['store_id']?.toString() ?? '',

      storeName:
      json['store_name']?.toString() ?? '',


      // ------------------------------------------------------
      // CHALLAN
      // ------------------------------------------------------

      challanNo:
      json['challan_no']?.toString() ?? '',

      challanDate:
      json['challan_date']?.toString() ?? '',


      // ------------------------------------------------------
      // LR
      // ------------------------------------------------------

      lrNo:
      json['lr_no']?.toString() ?? '',

      lrDate:
      json['lr_date']?.toString() ?? '',


      // ------------------------------------------------------
      // TRANSPORT
      // ------------------------------------------------------

      transportId:
      json['transport_id']?.toString() ?? '',

      transportName:
      json['transport_name']?.toString() ?? '',


      // ------------------------------------------------------
      // AGENT
      // ------------------------------------------------------

      agentId:
      json['agent_id']?.toString() ?? '',

      agentName:
      json['agent_name']?.toString() ?? '',


      // ------------------------------------------------------
      // AMOUNTS
      // ------------------------------------------------------

      valueOfGood:
      parseDouble(json['value_of_good']),

      additionalDiscountTotal:
      parseDouble(
        json['additional_discount_total'],
      ),

      additionalChargeValue:
      parseDouble(
        json['additional_charge_value'],
      ),

      finalDiscount:
      parseDouble(
        json['final_discount'],
      ),

      taxableAmount:
      parseDouble(
        json['taxable_amount'],
      ),


      // ------------------------------------------------------
      // TAX
      // ------------------------------------------------------

      sgst:
      parseDouble(json['sgst']),

      cgst:
      parseDouble(json['cgst']),

      igst:
      parseDouble(json['igst']),


      // ------------------------------------------------------
      // TOTAL
      // ------------------------------------------------------

      grandTotal:
      parseDouble(json['grand_total']),


      // ------------------------------------------------------
      // OTHER
      // ------------------------------------------------------

      remark:
      json['remark']?.toString() ?? '',

      createdAt:
      json['created_at']?.toString() ?? '',

      updatedAt:
      json['updated_at']?.toString() ?? '',


      // ------------------------------------------------------
      // ITEM COUNT
      // ------------------------------------------------------

      itemCount:
      int.tryParse(
        json['item_count']?.toString() ?? '0',
      ) ??
          0,
    );
  }
}