import 'dart:convert';
import 'dart:math' as math;

import 'package:calculation_panel/core/database/local_data/agent_json.dart';
import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/core/widget/widget_updater.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/pdf_genrate/challan_view.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/supplier_header/model/supplier_model.dart';
import 'package:flutter/material.dart';
import '../../../core/database/local_store_manager.dart';
import '../../../core/network/api_path.dart';
import '../../../core/network/api_repository.dart';
import '../../../core/ulitls/calculation.dart';
import '../../../core/widget/toast.dart';
import '../../other_charges/data/model/other_charge_model.dart';
import '../model/product_model.dart';
import '../model/store_model.dart';
import '../model/transport_model.dart';
import '../representaion/supplier_header/model/agent_model.dart';
import 'extra_charge_controller.dart';
import '../model/extra_charge_model.dart';
import '../model/purchase_model.dart';

class PurchaseController extends ChangeNotifier {
  PurchaseController();

  ExtraChargeController extraChargeController = ExtraChargeController();
  final TextEditingController lrNoController = TextEditingController();
  final TextEditingController lrDateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController applyDiscountController = TextEditingController();
  WidgetUpdater updateSummery = WidgetUpdater();
  double additionalChargeValue = 0.0;
  Party? selectSupplier;
  String gstNo = '';
  StoreModel? selectedStore;
  String challanNo = '';
  String selectedData = '';
  TransportModel? selectedTransport;
  Agency? selectedAgent;
  double finalDiscount = 0;
  bool isSubmitting = false;

  List<Agency> agents = [];

  double additionalDiscountTotal = 0.0;
  List<double> additionalDiscountList = [];
  List<double> additionalChargeList = [];
  final List<PurchaseItem> items = [];
  int get totalItems => items.length;
  List<ProductModel> products = [];
  String selectedDraft = '';



  Future<void> getAgentList(String search) async {
    Map<String, dynamic> requestBody = {};

    requestBody['search'] = search;
    requestBody['limit'] = "0";

    var response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.getAgentList,
      requestBody: requestBody,
      isFormData: true,
    );


    if(GlobalVars.isOffline)
    {
      response = agentJson;
    }

    if (response['error'] != null && response['error']) {
      try {
        var data = AgentResponseModel.fromJson(response);

        agents = data.agentList;

        notifyListeners();
      } catch (e) {
        print(e);
      }
    }

    notifyListeners();
  }


  List<OtherChargeModel> chargeData = [];

  void setDraftData(Map<String, dynamic> map) {
    extraChargeController.delItem();
    if (map['extraCharge'] != null) {
      if (map['extraCharge'] is List && map['extraCharge'].isNotEmpty) {
        for (var x in map['extraCharge']) {

          var extraCharges = ExtraChargeItemValue.fromJson(
            Map<String, dynamic>.from(x),
          );
          extraChargeController.setItem(extraCharges, data: chargeData);
        }
      }
      notifyListeners();
    }
    selectSupplier = map['selectSupplier'] != null
        ? Party.fromJson(Map<String, dynamic>.from(map['selectSupplier']))
        : null;

    gstNo = map['gstNo']?.toString() ?? '';

    selectedStore = map['selectedStore'] != null
        ? StoreModel.fromJson(Map<String, dynamic>.from(map['selectedStore']))
        : null;

    challanNo = map['challanNo']?.toString() ?? '';
    selectedData = map['selectedData']?.toString() ?? formatDate(DateTime.now());
    lrNoController.text = map['lrNo']?.toString() ?? '';
    lrDateController.text = map['lrDate']?.toString() ?? '';
    remarkController.text = map['remark']?.toString() ?? '';

    selectedTransport = map['selectedTransport'] != null
        ? TransportModel.fromJson(
            Map<String, dynamic>.from(map['selectedTransport']),
          )
        : null;

    selectedAgent = map['selectedAgent'] != null
        ? Agency.fromJson(Map<String, dynamic>.from(map['selectedAgent']))
        : null;

    additionalDiscountTotal =
        double.tryParse(map['additionalDiscountTotal']?.toString() ?? '') ??
        0.0;

    additionalDiscountList =
        (map['additionalDiscountList'] as List?)
            ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
            .toList() ??
        [];

    items.clear();

    items.addAll(
      (map['items'] as List?)
              ?.map((e) => PurchaseItem.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );

    additionalChargeValue = double.tryParse(map['additionalChargeValue']?.toString() ?? '') ?? 0.0;

    finalDiscount = double.tryParse(map['finalDiscount']?.toString() ?? '')?? 0;
  }
  void setFinalDiscount(String value){
    finalDiscount = double.tryParse(value)?? 0;
  }

  Map<String, dynamic> toDataMap() {
    return {
      'selectSupplier': selectSupplier?.toJson(),
      'gstNo': gstNo,
      'selectedStore': selectedStore?.toJson(),
      'challanNo': challanNo,
      'selectedData': selectedData,
      'lrNo': lrNoController.text,
      'lrDate': lrDateController.text,
      'remark': remarkController.text,
      'selectedTransport': selectedTransport?.toJson(),
      'selectedAgent': selectedAgent?.toJson(),
      'additionalDiscountTotal': additionalDiscountTotal,
      'additionalDiscountList': additionalDiscountList,
      'items': items
          .where(
            (e) =>
                e.productId != null &&
                e.product != null &&
                e.product!.name.isNotEmpty,
          )
          .map((e) => e.toJson())
          .toList(),
      'additionalChargeValue': additionalChargeValue,
      'extraCharge': extraChargeController.items
          .where((e) => e.itemValue.amount > 0)
          .map((e) => e.toDataMap())
          .toList(),
      'finalDiscount': finalDiscount,
      'valueOfGood': getTotalGoodsValue,
      'taxableDiscount': valueOfTaxableGoods(),
      'grandTotal': grandTotal.toStringAsFixed(2),
    };
  }
  
  Future<void> submitChallan()async{

    if (selectSupplier == null) {
      return;
    }

    var data =  toJsonMap();
    isSubmitting = true;
    updateSummery.update();
    await Future.delayed(Duration(milliseconds: 500));

    var response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.submitChallanApi,
        requestBody: data,
        isFormData: true
    );

    if(response['status']!=null && response['status'] == true)
      {
        print(response['message']);
        clearAll();
      }
    showMessage(response['message'], ToastType.info);
    isSubmitting = false;
    updateSummery.update();

  }

  Map<String, dynamic> toJsonMap() {
    
    return {
      'selectSupplier': selectSupplier?.id,
      'gstNo': gstNo,
      'selectedStore': selectedStore?.id ?? '',
      'challanNo': challanNo,
      'lrNo': lrNoController.text,
      'lrDate': lrDateController.text,
      'remark': remarkController.text,
      'selectedData': selectedData,
      'selectedTransport': selectedTransport?.id ?? '',
      'selectedAgent': selectedAgent?.id ?? '',
      'additionalDiscountTotal': additionalDiscountTotal.toString(),
      'items': jsonEncode(items
          .where(
            (e) =>
                e.productId != null &&
                e.product != null &&
                e.product!.name.isNotEmpty,
          )
          .map((e) => e.toJsonApi())
          .toList()),
      'additionalChargeValue': additionalChargeValue.toString(),
      'extraCharge': jsonEncode(extraChargeController.items
          .where((e) => e.itemValue.amount > 0)
          .map((e) => e.toApiMap())
          .toList()),
      'finalDiscount': finalDiscount.toString(),
      'valueOfGood': getTotalGoodsValue.toString(),
      'taxableAmount': valueOfTaxableGoods().toString(),
      if (selectSupplier?.state.id != GlobalVars.placeOfSupplyId) ...{
        'igst': igst.toString(),
        'sgst': '',
        'cgst': '',
      }
      else ...{
        'igst': '',
        'sgst': sgst.toString(),
        'cgst': cgst.toString(),
      },

      'grandTotal': grandTotal.toStringAsFixed(2),
    };
  }

  void update() {
    notifyListeners();
  }

  Future<bool> deleteDraftItem({
    required String partyId,
    required String draftId,
  }) async {
    var challanValue = await ChallanCartStorage.deleteDraftItemById(
      partyId: partyId,
      draftId: draftId,
    );
    return true;
  }

  Future<void> delAllDraft() async {
    // delete all data
    // await ChallanCartStorage.clearAll();
  }

  Future<void> getDraftData(String value) async {
    chargeData = await extraChargeController.searchOtherCharges('');

    selectedDraft = value;
    items.clear();

    String draftName = selectSupplier!.id;
    if (selectedDraft.isNotEmpty) {
      draftName = '${selectSupplier!.id}_$selectedDraft';
    }

    var challanValue = await ChallanCartStorage.get(draftName);
    if (challanValue != null) {
      setDraftData(challanValue);
    }

    notifyListeners();
  }

  void setSupplier(Party? value) async {
    if (selectSupplier != null) {
      if (items.isNotEmpty) {
        await ChallanCartStorage.save(toDataMap(), selectSupplier!.id);
      }
      extraChargeController.delItem();
      lrNoController.clear();
      lrDateController.clear();
      finalDiscount = 0;
    }

    items.clear();
    var challanValue = await ChallanCartStorage.get(value!.id);
    if (challanValue != null) {
      setDraftData(challanValue);
    }

    gstNo = value.gstNo;

    if (value.transport.name.isNotEmpty) {
      selectedTransport = TransportModel(
        id: value.transport.id,
        transport: value.transport.name,
        owner: '',
        mobile: '',
        location: '',
        address: '',
      );
      selectedAgent = value.agency;
    }

    if (items.isEmpty) {
      addItem();
    }
    notifyListeners();
    selectSupplier = value;
    getProductList('');
  }

  void setStore(StoreModel? store) {
    selectedStore = store;
  }

  void setTransport(TransportModel? transport) {
    selectedTransport = transport;
  }

  void setData(String value) {
    selectedData = value;
  }

  void setChallanNo(String challan, String gst) {
    challanNo = challan;
    gstNo = gst;
  }

  void selectProduct(PurchaseItem item, ProductModel product, {String? qty}) {
    item.productId = product.id;
    item.product = product;
    item.nameController.text = product.name ?? "";
    item.brandController.text = product.brand!.name ?? "";
    item.quantityController.text = qty ?? '1';
    item.discountController.text = '0';
    notifyListeners();
  }

  Future<List<ProductModel>> getProductList(String search) async {
    if (selectSupplier == null) {
      showMessage("Please select supplier", ToastType.error);
      return [];
    }

    Map<String, dynamic> requestBody = {};
    requestBody['SupplierId'] = selectSupplier != null
        ? selectSupplier!.id
        : "";
    requestBody['BillDate'] = GlobalVars.currentData;
    requestBody['search'] = search;
    requestBody['limit'] = "0";
    var response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.getProductList,
      requestBody: requestBody,
      isFormData: true,
    );

    if (response['error'] != null && response['error']) {
      try {
        var data = ProductListResponse.fromJson(response);
        products = data.productList;
      } catch (e) {}
    } else {
      products.clear();
    }

    notifyListeners();
    return products;
  }

  int get totalQuantity {
    int total = 0;

    for (final item in items) {
      total += item.quantity;
    }
    return total;
  }

  // ============================================================
  // VALUE OF GOODS
  // ============================================================

  double valueOfTaxableGoods() {
    for (var x = 0; x < items.length; x++) {
      items[x].extraDiscount = x < additionalDiscountList.length ? (additionalDiscountList[x] ) : 0.0;
      items[x].extraCharge = x < additionalChargeList.length ? (additionalChargeList[x] ) : 0.0;
    }
    return getTotalGoodsAfterDiscountValue;
  }


  double get getTotalGoodsValue {
    double total = 0;
    for (var x in items) {
      total += x.getItemTotalAmount;
    }
    return total;
  }

  double get getTotalGoodsAfterDiscountValue {
    double total = 0;
    for (var x in items) {
      total += x.getFinalPriceAfterDiscount;
    }
    return total;
  }

  // ============================================================
  // DISCOUNT
  // ============================================================

  double get appliedDiscount {
    return _parseDouble(applyDiscountController.text);
  }

  void applyDiscountAll() {
    for (var x in items) {
      x.discountController.text = appliedDiscount.toString();
      if (x.product != null) {
        x.product!.discount = appliedDiscount.toString();
      }
    }
    applyDiscountController.clear();
    notifyListeners();
  }

  double get additionalCharge {
    return additionalChargeValue;
  }

  // ============================================================
  // GST
  // ============================================================

  double get sgst {
    double sgstValue = 0.0;

    for (final item in items) {
      final double tax = double.tryParse(item.getGST) ?? 0.0;
      sgstValue += (item.getFinalPriceAfterDiscount* (tax / 2)) / 100;
    }

    return sgstValue;
  }

  double get cgst {
    double cgstValue = 0.0;

    for (final item in items) {
      final double tax = double.tryParse(item.getGST) ?? 0.0;
      cgstValue += (item.getFinalPriceAfterDiscount* (tax / 2)) / 100;
    }

    return cgstValue;
  }

  double get igst {
    double igstValue = 0.0;
    for (final item in items) {
      final double tax = double.tryParse(item.getGST) ?? 0.0;
      igstValue += (item.getFinalPriceAfterDiscount * (tax)) / 100;
    }

    return igstValue;
  }

  // ============================================================
  // GRAND TOTAL
  // ============================================================

  double get grandTotal {
    return valueOfTaxableGoods() +
        sgst +
        cgst +
        additionalChargeValue -
        finalDiscount;
  }

  // ============================================================
  // SAFE DOUBLE PARSER
  // ============================================================

  double _parseDouble(String value) {
    return double.tryParse(value.trim()) ?? 0;
  }

  // ============================================================
  // AGENT
  // ============================================================

  void setAgent(Agency? value) {
    if (selectedAgent == value) return;
    selectedAgent = value;
    notifyListeners();
  }

  // ============================================================
  // ADDITIONAL CHARGE TYPE
  // ============================================================

  void setAdditionalDiscount(double? value) {
    additionalDiscountTotal = value ?? 0;
  }

  void setAdditionalDiscountByCat(List<double> value) {
    additionalDiscountList = value;
  }
  void setAdditionalChargeByCat(List<double> value) {
    additionalChargeList = value;
  }

  void setAdditionalCharge(double? value) {
    additionalChargeValue = value ?? 0;
  }

  // ============================================================
  // LR DATE
  // ============================================================

  Future<void> selectLrDate(BuildContext context) async {
    final currentDate = _parseDate(lrDateController.text);

    final result = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xff2563EB)),
          ),
          child: child!,
        );
      },
    );

    if (result == null) return;

    lrDateController.text = _formatDate(result);

    notifyListeners();
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // PARSE DATE
  // ============================================================

  DateTime? _parseDate(String value) {
    final parts = value.split('/');

    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);

    final month = int.tryParse(parts[1]);

    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // ADD ITEM
  // ============================================================

  void addItem() {
    final item = PurchaseItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      onChanged: notifyListeners,
    );

    item.quantityController.text = '1';
    item.priceController.text = '0';
    item.mrpRateController.text = '0';
    item.wholesaleRateController.text = '0';
    item.retailRateController.text = '0';
    item.discountController.text = '0';

    items.add(item);

    notifyListeners();
  }

  // ============================================================
  // REMOVE ITEM
  // ============================================================

  void removeItem(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }

    if (items.length == 1) {
      addItem();
    }

    final item = items.removeAt(index);

    item.dispose();

    notifyListeners();
  }

  // ============================================================
  // UPDATE ITEM
  // ============================================================

  void updateItem(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }

    notifyListeners();
  }

  // ============================================================
  // CLEAR ITEMS
  // ============================================================

  void clearItems() {
    for (final item in items) {
      item.dispose();
    }

    items.clear();

    notifyListeners();
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  void clearAll() {
    lrNoController.clear();

    lrDateController.clear();

    remarkController.clear();

    applyDiscountController.text = '0';

    selectedAgent = null;

    additionalChargeValue = 0;

    for (final item in items) {
      item.dispose();
    }

    items.clear();
    extraChargeController.delItem();

    notifyListeners();
  }

  // ============================================================
  // GENERATE CHALLAN
  // ============================================================

  void generateChallan(
    BuildContext context,
    PurchaseController controller,
    ExtraChargeController extraCharge,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallanPage(
          controller: controller,
          extraChargeController: extraCharge,
        ),
      ),
    );

    debugPrint('======================================');

    debugPrint('Generating Purchase Challan');

    debugPrint('Agent: $selectedAgent');

    debugPrint('Total Items: $totalItems');

    debugPrint('Total Quantity: $totalQuantity');

    debugPrint('Value of Goods: $valueOfTaxableGoods');

    debugPrint('Discount: $applyDiscountController');

    debugPrint('Additional Charge: $additionalCharge');

    debugPrint('SGST: $sgst');

    debugPrint('CGST: $cgst');

    debugPrint('Grand Total: $grandTotal');

    debugPrint('======================================');

    // TODO:
    // API CALL
  }

  @override
  Future<void> dispose() async {
    if (selectSupplier != null) {
      if (items.isNotEmpty) {
        await ChallanCartStorage.save(toDataMap(), selectSupplier!.id);
      }
    }

    lrNoController.dispose();
    lrDateController.dispose();
    remarkController.dispose();
    applyDiscountController.dispose();

    for (final item in items) {
      item.dispose();
    }

    items.clear();
    super.dispose();
  }
}
