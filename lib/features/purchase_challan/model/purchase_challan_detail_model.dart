
import 'package:calculation_panel/core/database/local_data/party_json.dart';
import 'package:calculation_panel/core/widget/series_field.dart';
import 'package:calculation_panel/features/purchase_challan/model/color_model.dart';
import 'package:calculation_panel/features/purchase_challan/model/party_model.dart';
import 'package:calculation_panel/features/purchase_challan/model/product_model.dart';
import 'package:calculation_panel/features/purchase_challan/model/purchase_model.dart';
import 'package:calculation_panel/features/purchase_challan/model/size_model.dart';
import 'package:calculation_panel/features/purchase_challan/model/transport_model.dart';
import 'package:calculation_panel/features/purchase_challan/model/supplier_model.dart';
import '../../dashboard/model/store_model.dart';
import '../../dashboard/model/transport_model.dart';
import 'hsn_model.dart';

class PurchaseChallanDetails {
  final String id;
  final String supplierId;
  final String company;
  final String seriesId;
  final String seriesName;
  final String gstNo;
  final String storeId;
  final String storeName;
  final String challanNo;
  final String rereferenceNo;
  final String challanDate;
  final String lrNo;
  final String lrDate;
  final String transportId;
  final String transportName;
  final String agentId;
  final String agentName;
  final String valueOfGood;
  final String additionalDiscountTotal;
  final String additionalChargeValue;
  final String finalDiscount;
  final String taxableAmount;
  final String sgst;
  final String cgst;
  final String igst;
  final String grandTotal;
  final String remark;
  final String createdAt;
  final String updatedAt;
  final List<PurchaseChallanItem> items;
  final List<PurchaseChallanExtraCharge> extraCharge;
  final String itemsCount;
  final String extraChargesCount;


  PurchaseChallanDetails({
    required this.id,
    required this.supplierId,
    required this.seriesId,
    required this.seriesName,
    required this.company,
    required this.gstNo,
    required this.storeId,
    required this.storeName,
    required this.challanNo,
    required this.rereferenceNo,
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
    required this.items,
    required this.extraCharge,
    required this.itemsCount,
    required this.extraChargesCount,
  });

  factory PurchaseChallanDetails.fromJson(Map<String, dynamic> json) {
    return PurchaseChallanDetails(
      id: json['id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? '',
      seriesId: json['series_id']?.toString() ?? '',
      seriesName: json['series_name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      gstNo: json['gst_no']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      challanNo: json['challan_no']?.toString() ?? '',
      rereferenceNo:json['reference_no']?.toString() ?? '',
      challanDate: json['challan_date']?.toString() ?? '',
      lrNo: json['lr_no']?.toString() ?? '',
      lrDate: json['lr_date']?.toString() ?? '',
      transportId: json['transport_id']?.toString() ?? '',
      transportName: json['transport_name']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      agentName: json['agent_name']?.toString() ?? '',
      valueOfGood: json['value_of_good']?.toString() ?? '0',
      additionalDiscountTotal:
      json['additional_discount_total']?.toString() ?? '0',
      additionalChargeValue:
      json['additional_charge_value']?.toString() ?? '0',
      finalDiscount: json['final_discount']?.toString() ?? '0',
      taxableAmount: json['taxable_amount']?.toString() ?? '0',
      sgst: json['sgst']?.toString() ?? '0',
      cgst: json['cgst']?.toString() ?? '0',
      igst: json['igst']?.toString() ?? '0',
      grandTotal: json['grand_total']?.toString() ?? '0',
      remark: json['remark']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map(
            (e) => PurchaseChallanItem.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
      extraCharge: (json['extraCharge'] as List<dynamic>?)
          ?.map(
            (e) => PurchaseChallanExtraCharge.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
      itemsCount: json['itemsCount']?.toString() ?? '0',
      extraChargesCount: json['extraChargesCount']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'company':company,
      'seriesId': seriesId,
      'seriesName':seriesName,
      'gst_no': gstNo,
      'store_id': storeId,
      'store_name': storeName,
      'challan_no': challanNo,
      'reference_no':rereferenceNo,
      'challan_date': challanDate,
      'lr_no': lrNo,
      'lr_date': lrDate,
      'transport_id': transportId,
      'transport_name': transportName,
      'agent_id': agentId,
      'agent_name': agentName,
      'value_of_good': valueOfGood,
      'additional_discount_total': additionalDiscountTotal,
      'additional_charge_value': additionalChargeValue,
      'final_discount': finalDiscount,
      'taxable_amount': taxableAmount,
      'sgst': sgst,
      'cgst': cgst,
      'igst': igst,
      'grand_total': grandTotal,
      'remark': remark,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items.map((e) => e.toJson()).toList(),
      'extraCharge': extraCharge.map((e) => e.toJson()).toList(),
      'itemsCount': itemsCount,
      'extraChargesCount': extraChargesCount,
    };
  }

  Map<String, dynamic> toDataMap() {

    Party? selectSupplier = getSupplierName(supplierId);
    TransportModel? selectedTransport = TransportModel(id: transportId, transport: transportName, owner: '', mobile: '', location: '', address: '');
    Agency? selectedAgent = Agency(id: agentId, name: agentName);
    StoreModel? selectedStore = StoreModel(id: storeId, store: storeName, shortName: storeName);
    Series series = Series(id: seriesId, name: seriesName, voucherType: '', store: '');

    return {
      'selectSupplier': selectSupplier?.toJson(),
      'selectedSeries':series?.toJson(),
      'gstNo': gstNo,
      'selectedStore': selectedStore.toJson(),
      'challanNo': challanNo,
      'selectedData': challanDate,
      'lrNo': lrNo,
      'lrDate': lrDate,
      'remark': remark,
      'selectedTransport': selectedTransport.toJson(),
      'selectedAgent': selectedAgent.toJson(),
      'additionalDiscountTotal': additionalDiscountTotal,
      'additionalDiscountList': [],
      'items': items
          .map((e) => PurchaseItem(id: e.id, extraCharge: double.tryParse(e.extraCharge)?? 0,  extraDiscount: double.tryParse(e.extraDiscount)?? 0, productId: e.productId, product: ProductModel(id:e.productId, name: e.productName, qty: e.itemQty, barcode: e.barcode, hsnCode:HsnCodeModel(id: e.hsn, name: ''), size: SizeModel(id: e.size, sizeName: e.sizeName), discount: e.discountPer, color: ColorModel(id: e.color, colorName: e.colorName), purchaseRate: e.amount, mrp: e.mrp , b2bPrice: e.wholesale, b2cPrice: e.retail, brand: BrandModel(id: '', name: e.brand), hsnTaxSlab: e.hsnTaxSlabs ), onChanged: () {  }).toJson())
          .toList(),
      'additionalChargeValue': additionalChargeValue,
      'extraCharge': extraCharge
          .map((e) => {
        'id': e.id,
        'name': e.name,
        'amount': e.amount,
        'taxPercent': e.taxPercent,
        'taxType': e.taxType,
        'isDiscount': e.isDiscount=='1'? true: false,
        'isTaxApplicable': e.isTaxApplicable,
        'itemWiseDistribution': '',
      })
          .toList(),
      'finalDiscount': finalDiscount,
      'valueOfGood': valueOfGood,
      'taxableDiscount': taxableAmount,
      'grandTotal': grandTotal,
    };
  }

}


class PurchaseChallanItem {
  final String id;
  final String challanId;

  final String productId;
  final String productName;

  final String amount;
  final String mrp;
  final String wholesale;
  final String retail;
  final String itemQty;

  final String size;
  final String sizeName;

  final String color;
  final String colorName;
  final String barcode;

  final String brand;

  final String hsn;
  final String discountPer;
  final String extraDiscount;
  final String extraCharge;
  final String gst;
  final String itemFinalPrice;
  List<HsnTaxSlab> hsnTaxSlabs  = [];


  PurchaseChallanItem({
    required this.id,
    required this.challanId,
    required this.productId,
    required this.productName,
    required this.amount,
    required this.mrp,
    required this.wholesale,
    required this.retail,
    required this.itemQty,
    required this.size,
    required this.sizeName,
    required this.color,
    required this.colorName,
    required this.barcode,
    required this.hsn,
    required this.discountPer,
    required this.extraDiscount,
    required this.extraCharge,
    required this.gst,
    required this.itemFinalPrice,
    required this.brand,
  });

  factory PurchaseChallanItem.fromJson(
      Map<String, dynamic> json,
      ) {
    return PurchaseChallanItem(
      id: json['id']?.toString() ?? '',

      challanId:
      json['challan_id']?.toString() ?? '',

      productId:
      json['product_id']?.toString() ?? '',

      productName:
      json['product_name']?.toString() ?? '',
      brand: json['brand_name']?.toString() ?? '',

      amount:
      json['amount']?.toString() ?? '0',
      mrp:
      json['mrp']?.toString() ?? '0',
      wholesale:
      json['b2b']?.toString() ?? '0',
      retail:
      json['b2c']?.toString() ?? '0',

      itemQty:
      json['item_qty']?.toString() ?? '0',

      size:
      json['size']?.toString() ?? '',

      sizeName:
      json['size_name']?.toString() ?? '',

      color:
      json['color']?.toString() ?? '',

      colorName:
      json['color_name']?.toString() ?? '',

      barcode: json['barcode']?.toString() ?? '',

      hsn:
      json['hsn']?.toString() ?? '',

      discountPer:
      json['discount_per']?.toString() ?? '0',

      extraDiscount:
      json['extra_discount']?.toString() ?? '0',

      extraCharge:
      json['extra_charge']?.toString() ?? '0',

      gst:
      json['gst']?.toString() ?? '0',

      itemFinalPrice:
      json['item_final_price']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challan_id': challanId,

      'product_id': productId,
      'product_name': productName,
      'brand_name': brand,

      'amount': amount,
      'mrp': mrp,
      'b2b': wholesale,
      'b2c': retail,
      'item_qty': itemQty,

      'size': size,
      'size_name': sizeName,

      'color': color,
      'color_name': colorName,

      'barcode': barcode,

      'hsn': hsn,
      'discount_per': discountPer,
      'extra_discount': extraDiscount,
      'extra_charge': extraCharge,
      'gst': gst,
      'item_final_price': itemFinalPrice,
    };
  }
}

class PurchaseChallanExtraCharge {
  final String id;
  final String challanId;
  final String chargeId;
  final String name;
  final String amount;
  final String taxPercent;
  final String taxType;
  final String isDiscount;
  final String isTaxApplicable;

  PurchaseChallanExtraCharge({
    required this.id,
    required this.challanId,
    required this.chargeId,
    required this.name,
    required this.amount,
    required this.taxPercent,
    required this.taxType,
    required this.isDiscount,
    required this.isTaxApplicable,
  });

  factory PurchaseChallanExtraCharge.fromJson(
      Map<String, dynamic> json,
      ) {
    return PurchaseChallanExtraCharge(
      id: json['id']?.toString() ?? '',
      challanId: json['challan_id']?.toString() ?? '',
      chargeId: json['charge_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      taxPercent: json['tax_percent']?.toString() ?? '0',
      taxType: json['tax_type']?.toString() ?? '',
      isDiscount: json['is_discount']?.toString() ?? '0',
      isTaxApplicable: json['is_tax_applicable']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challan_id': challanId,
      'charge_id': chargeId,
      'name': name,
      'amount': amount,
      'tax_percent': taxPercent,
      'tax_type': taxType,
      'is_discount': isDiscount,
      'is_tax_applicable': isTaxApplicable,
    };
  }
}