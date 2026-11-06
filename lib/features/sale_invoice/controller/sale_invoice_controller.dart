import 'dart:convert';
import 'package:calculation_panel/core/database/local_data/agent_json.dart';
import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/core/widget/widget_updater.dart';
import 'package:calculation_panel/features/purchase_challan/model/supplier_model.dart';
import 'package:calculation_panel/features/sale_invoice/model/sale_model.dart';
import 'package:flutter/material.dart';
import '../../../core/database/local_data/product_json.dart';
import '../../../core/database/local_store_manager.dart';
import '../../../core/database/sql_databaes/purchase_challan_database.dart';
import '../../../core/enums/enums.dart';
import '../../../core/network/api_path.dart';
import '../../../core/network/api_repository.dart';
import '../../../core/widget/ratetype_field.dart';
import '../../../core/widget/toast.dart';
import '../../dashboard/model/store_model.dart';
import '../../other_charges/data/model/other_charge_model.dart';
import '../../purchase_challan/controller/extra_charge_controller.dart';
import '../../purchase_challan/model/extra_charge_model.dart';
import '../../purchase_challan/model/party_model.dart';
import '../../purchase_challan/model/product_model.dart';
import '../../purchase_challan/model/purchase_challan_detail_model.dart';
import '../../purchase_challan/model/agent_model.dart';
import '../../purchase_challan/model/transport_model.dart';

class SaleInvoiceController extends ChangeNotifier {
  SaleInvoiceController({this.productPageType=ProductPageType.purchase});

  final ProductPageType productPageType;

  ExtraChargeController extraChargeController = ExtraChargeController();
  final TextEditingController lrNoController = TextEditingController();
  final TextEditingController lrDateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController applyDiscountController = TextEditingController();
  WidgetUpdater updateSummery = WidgetUpdater();
  double additionalChargeValue = 0.0;
  Party? selectSupplier;
  TransportModel? selectedTransport;
  Agency? selectedAgent;
  String gstNo = '';
  StoreModel? selectedStore;
  String challanNo = '';
  String selectedData = '';

  double finalDiscount = 0;
  bool isSubmitting = false;
  String updateId = '';
  List<Agency> agents = [];
  double additionalDiscountTotal = 0.0;
  List<double> additionalDiscountList = [];
  List<double> additionalChargeList = [];
  final List<SaleItem> items = [];
  int get totalItems => items.length;
  List<ProductModel> products = [];
  String selectedDraft = '';

  RateType? rateType;

  PurchaseChallanDetails? purchaseChallanDetails;

  Future<void> updateProducts() async {
    try {
      for (final product in productJson['data'] as List<dynamic>) {

        final Map<String, dynamic> requestBody = {
          'id': product['id']?.toString() ?? '',
          'product': product['product']?.toString() ?? '',
          'supl_name': product['supl_name']?.toString() ?? '',
          'category': product['category']?.toString() ?? '',
          'hsncode': jsonEncode(product['hsncode'] ?? {}),
          'brand': jsonEncode(product['brand'] ?? {}),
          'HSNTaxSlab': jsonEncode(product['HSNTaxSlab'] ?? []),
        };
        final response = await ApiProvider.createServerRequest(
          apiUrl: ApiPath.addProduct,
          requestBody: requestBody,
          isFormData: true,
        );

        await Future.delayed(Duration(milliseconds: 200));

        print('Response: $response');
      }
    } catch (e) {
      print('Product update error: $e');
    }
  }


  Future<void> getPreviousData(String id)async {
    updateId = id;
    Map<String, dynamic> requestBody = {};
    requestBody['id'] = updateId;

    var response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.purchaseChallansDetailApi,
      requestBody: requestBody,
      isFormData: true,
    );

    if (response['status'] != null && response['status']) {
      try {

        purchaseChallanDetails = PurchaseChallanDetails.fromJson(response['data']);
        if(purchaseChallanDetails!=null) {
          setDraftData(purchaseChallanDetails!.toDataMap());
        }
      } catch (e) {
        print(e);
      }
    }

    notifyListeners();

  }

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

    selectedAgent = map['selectedAgent']!= null
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


    ///will be check later
    /*items.addAll(
      (map['items'] as List?)
          ?.map((e) => PurchaseItem.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
    );*/

    for(var x in items)
    {
      print(x.toJson());

    }

    additionalChargeValue = double.tryParse(map['additionalChargeValue']?.toString() ?? '') ?? 0.0;

    finalDiscount = double.tryParse(map['finalDiscount']?.toString() ?? '')?? 0;

    print(gstNo);
    print(selectedStore?.toJson());

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

  Future<void> submitChallan(bool isEdit)async{

    if (selectSupplier == null) {
      return;
    }

    var data =  toJsonMap();
    isSubmitting = true;
    updateSummery.update();
    await Future.delayed(Duration(milliseconds: 500));

    try {
      if (GlobalVars.isOffline) {
        // TODO: convert your `data` into the format
        // required by saveCompletePurchase()

        final purchaseId = await PurchaseDatabase.instance.saveCompletePurchase(data);


        showMessage(
          purchaseId==0? 'Challan already exists': 'Challan saved offline',
          ToastType.info,
        );

        if(purchaseId!=0) {
          clearAll();
        }
      } else {
        print(data);
        Map<String, dynamic> response = {};
        if(isEdit)
        {
          var requestBody = data;
          requestBody['id']= updateId;

          response = await ApiProvider.createServerRequest(
            apiUrl: ApiPath.updateChallanApi,
            requestBody: requestBody,
            isFormData: true,
          );
        } else {
          response = await ApiProvider.createServerRequest(
            apiUrl: ApiPath.submitChallanApi,
            requestBody: data,
            isFormData: true,
          );
        }


        if (response['status'] != null &&
            response['status'] == true) {

          clearAll();
        }

        showMessage(
          response['message'],
          ToastType.info,
        );
      }
    } catch (e) {
      print('Submit challan error: $e');

      showMessage(
        'Something went wrong: $e',
        ToastType.info,
      );
    } finally {
      isSubmitting = false;
      updateSummery.update();
    }

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
      'status': 'pending',
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
      if (selectSupplier?.state!.id != GlobalVars.placeOfSupplyId) ...{
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
      draftId: draftId,
      challanType: '', supplierId: '',
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

  Future<void> setSupplier(Party? value) async {
    // if (selectSupplier != null && items.isNotEmpty) {
    //   await ChallanCartStorage.save(
    //     toDataMap(),
    //     selectSupplier!.id,
    //   );
    // }

    extraChargeController.delItem();
    lrNoController.clear();
    lrDateController.clear();
    finalDiscount = 0;

    items.clear();
    selectSupplier = value;

    // Handle supplier cleared / null selection
    if (value == null) {
      gstNo = '';
      selectedTransport = null;

      addItem();
      notifyListeners();
      getProductList('');
      return;
    }

    // Restore saved draft for selected supplier
    final challanValue = await ChallanCartStorage.get(value.id);

    if (challanValue != null) {
      setDraftData(challanValue);
    }

    gstNo = value.gstNo;

    // Set supplier transport
    if (value.transport != null &&
        value.transport!.name.isNotEmpty) {
      selectedTransport = TransportModel(
        id: value.transport?.id ?? '',
        transport: value.transport?.name ?? '',
        owner: '',
        mobile: '',
        location: '',
        address: '',
      );
    } else {
      selectedTransport = null;
    }

    if (items.isEmpty) {
      addItem();
    }

    notifyListeners();
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

  void selectProduct(SaleItem item, ProductModel product, {String? qty}) async{
    item.productId = product.id;
    item.product = product;
    item.nameController.text = product.name ?? "";
    item.brandController.text = product.brand!.name ?? "";
    item.quantityController.text = qty ?? '1';
    item.discountController.text = '0';
    await applyRateTypeOnItem(item);
    notifyListeners();
  }

  Future<List<ProductModel>> getProductList(String search) async {

    Map<String, dynamic> requestBody = {};
    requestBody['search'] = search;
    requestBody['limit'] = "0";
    var response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.saleProductList,
      requestBody: requestBody,
      isFormData: true,
    );
    printLog('productDebug000: ${response}');
    if (response['error'] != null && response['error']) {
      try {
        printLog('productDebug001: ${response}');
        var data = ProductListResponse.fromJson(response);
        printLog('productDebug002: ${data.productList.length}');
        products = data.productList;
        printLog('productDebug003: ${products}');
      } catch (e) {
        printLog('productDebug004: ${e}');
      }
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
    printLog('addMessage001');
    final item = SaleItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      onChanged: notifyListeners,
    );

    item.quantityController.text = '1';
    item.discountController.text = '0';

    items.add(item);
    printLog('addMessage002');
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

  Future<void> applyRateTypeOnItem(SaleItem saleItem) async{
    if(rateType==null){
      saleItem.priceController.text = saleItem.product!.b2bPrice ?? '0';
    }
    else if(rateType!.id=='1'){
      saleItem.priceController.text = saleItem.product!.b2bPrice ?? '0';
    }
    else if(rateType!.id=='2'){
      saleItem.priceController.text =  saleItem.product!.mrp ?? '0';
    }
    else if(rateType!.id=='3'){
      saleItem.priceController.text = saleItem.product!.b2cPrice ?? '0';
    }
    saleItem.setDiscountedAmount();
    printLog('rateDebug002: ${saleItem.priceController.text}');
    return;
  }

  void applyRateType(RateType rateType) {
    this.rateType = rateType;
    final selectedType = rateType.name.trim().toLowerCase();

    for (final item in items) {
      final product = item.product;

      if (product == null) continue;

      String? selectedPrice;

      switch (selectedType) {
        case 'mrp':
          selectedPrice = product.mrp;
          break;

        case 'wholesale':
          selectedPrice = product.b2bPrice;
          break;

        case 'retail':
          selectedPrice = product.b2cPrice;
          break;

        default:
          continue;
      }

      if (selectedPrice == null || selectedPrice.trim().isEmpty) {
        continue;
      }

      // Update the selling price for this row.
      item.priceController.text = selectedPrice;

      // Recalculate the row's amount without overwriting its original rates.
      item.setDiscountedAmount();
    }

    // Refresh the product table and invoice totals.
    notifyListeners();
  }



  @override
  Future<void> dispose() async {
    if (selectSupplier != null) {
      if (items.isNotEmpty) {
        // await ChallanCartStorage.save(toDataMap(), selectSupplier!.id);
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
