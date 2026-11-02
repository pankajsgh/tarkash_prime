import 'dart:convert';
import 'dart:math' as math;
import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/core/widget/widget_updater.dart';
import 'package:flutter/material.dart';
import '../../../core/compair.dart';
import '../../../core/database/local_data/product_json.dart';
import '../../../core/database/local_store_manager.dart';
import '../../../core/network/api_path.dart';
import '../../../core/network/api_repository.dart';
import '../../../core/widget/series_field.dart';
import '../../../core/widget/toast.dart';
import '../../dashboard/model/store_model.dart';
import '../../other_charges/data/model/other_charge_model.dart';
import '../model/hsn_model.dart';
import '../model/party_model.dart';
import '../model/product_model.dart';
import '../model/purchase_challan_detail_model.dart';
import '../model/transport_model.dart';
import '../model/agent_model.dart';
import 'extra_charge_controller.dart';
import '../model/extra_charge_model.dart';
import '../model/purchase_model.dart';




class PurchaseController extends ChangeNotifier {
  PurchaseController({
    required this.submitChallanApi,
    required this.updateChallanApi,
    required this.draftType,
 });

  String submitChallanApi ='';
  String updateChallanApi ='';
  String draftType = '';

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
  final List<PurchaseItem> items = [];
  int get totalItems => items.length;
  List<ProductModel> products = [];
  String selectedDraft = '';
  Series? selectedSeries;
  String? referenceNo;
  PurchaseChallanDetails? purchaseChallanDetails;
  Map<String, dynamic> previousAPIData = {};

  void setSeries(Series? value){
    selectedSeries = value;
  }

  String draftListKey(String supplierId) {
    return '${draftType}_draft_$supplierId';
  }

  String draftDataKey(String supplierId, String draftName) {
    return '${draftType}_${supplierId}_${draftName.trim()}';
  }

 Future<void> getPreviousData(String id)async {
   updateId = id;
   Map<String, dynamic> requestBody = {};
   requestBody['id'] = updateId;

   var detailApi = draftType=="purchase_challan" ? ApiPath.purchaseChallansDetailApi: ApiPath.supplierVoucherDetailApi;

   print(detailApi);

   var response = await ApiProvider.createServerRequest(
     apiUrl: detailApi,
     requestBody: requestBody,
     isFormData: true,
   );

   if (response['status'] != null && response['status']) {
     try {

       purchaseChallanDetails = PurchaseChallanDetails.fromJson(response['data']);

       if(purchaseChallanDetails!=null) {
         previousAPIData = response['data'];
         selectSupplier = Party(id: purchaseChallanDetails!.supplierId, customerCode: '', userType: '', company: purchaseChallanDetails!.company, printName: '', name: '', mobile: '', gstNo: gstNo, status: '', address: '', pincode: '', discount: '', partyType: '');
       }


       if(purchaseChallanDetails!=null) {

         referenceNo = purchaseChallanDetails!.rereferenceNo;

         for(var x in  purchaseChallanDetails!.items)
           {
             List<HsnTaxSlab> hsnTaxSlab =  await getHsnTaxSlab(x.productId);

             x.hsnTaxSlabs = hsnTaxSlab;
           }



         setDraftData(purchaseChallanDetails!.toDataMap());
       }
     } catch (e) {
       print(e);
     }
   }
   notifyListeners();
 }

  Future<void> updateProducts() async {
    try {
      for (final product in productJson['ProductList'] as List<dynamic>) {

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


  Future<List<HsnTaxSlab>> getHsnTaxSlab(
      String productId,
      ) async {
    try {
      final Map<String, String> requestData = {
        'product_id': productId,
      };

      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.productTaxSlabs,
        requestBody: requestData,
        isFormData: true,
      );

      debugPrint('HSN Tax Slab Response: $response');

      final Map<String, dynamic> responseData =
      Map<String, dynamic>.from(response);

      // Your API:
      // error = true  -> SUCCESS
      // error = false -> ERROR

      if (responseData['error'] != true) {
        debugPrint(
          'HSN Tax Slab Error: '
              '${responseData['message']?.toString() ?? 'Unknown error'}',
        );
        return [];
      }

      final List<dynamic> slabData =
          responseData['HSNTaxSlab'] as List<dynamic>? ?? [];

      return slabData
          .map(
            (item) => HsnTaxSlab.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (e) {
      debugPrint('getHsnTaxSlab Error: $e');
      return [];
    }
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


    var supplierData = map['selectSupplier'] != null
        ? Party.fromJson(Map<String, dynamic>.from(map['selectSupplier']))
        : null;


    if(supplierData!=null)
    {
      if(selectSupplier!=null)
      {
        selectSupplier!.agency = supplierData.agency;
        selectSupplier!.transport = supplierData.transport;
      } else {
        selectSupplier = supplierData;
      }
    }

    if(map['selectedTransport']!=null) {
      selectSupplier!.transport = Transport(id: map['selectedTransport']['id']?? '', name: map['selectedTransport']['transport']?? '');
    }

    selectedSeries = map['selectedSeries'] != null
        ? Series.fromJson(Map<String, dynamic>.from(map['selectedSeries']))
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


   items.addAll(
     (map['items'] as List?)
         ?.map(
           (e) => PurchaseItem.fromJson(
         Map<String, dynamic>.from(e as Map),
       ),
     )
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
      'selectedSeries': selectedSeries?.toJson(),
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
  
  Future<bool?> submitChallan(bool isEdit)async{

    if (selectSupplier == null) {
      return null;
    }

    var data =  toJsonMap();
    isSubmitting = true;
    updateSummery.update();
    await Future.delayed(Duration(milliseconds: 500));

    try
    {
        Map<String, dynamic> response = {};
        if(isEdit)
          {


            final Map<String, dynamic> changed = getPurchaseChallanChanges(
              postData: data,
              fetchedData: previousAPIData,
            );

            if (changed.isEmpty) {

              showMessage(
                'No changes detected',
                ToastType.error,
              );
              return false;
            } else {
              debugPrint('changes detected');
              debugPrint(changed.toString());
              var requestBody = data;
              requestBody['id']= updateId;

              response = await ApiProvider.createServerRequest(
                apiUrl: updateChallanApi,
                requestBody: requestBody,
                isFormData: true,
              );
            }

          } else {
          response = await ApiProvider.createServerRequest(
            apiUrl: submitChallanApi,
            requestBody: data,
            isFormData: true,
          );
        }


        if (response['error'] != null &&
            response['error'] == true) {
          showMessage(
            response['msg']?? "",
            ToastType.success,
          );
          clearAll();
          return true;
        } else
          {
            showMessage(
              response['msg']?? "",
              ToastType.error,
            );
          }

        print('Submit challan Detail');
        print(response);


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


    return null;

  }


  Future<Map<String, dynamic>> addProductParameters({
    required String productId,
    required Map<String, String> item,
  }) async {
    try {
      final String barcodePrefix = await loadBarcodePrefix();
      final String updateExisting = await loadMultipleBarcode();

      final requestBody = {
        'product_id': productId,
        'barcode_prefix': barcodePrefix,
        'update_existing': updateExisting.toString(),
        'product_parameters': jsonEncode(item),
      };

      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.addProductParameterApi,
        requestBody: requestBody,
        isFormData: true,
      );

      print(response);

      if (response['error'] == true) {
        final data = response['data'];

        return {
          'code': response['code'] ?? 1,
          'error': true,
          'message': response['message']?.toString() ??
              'Product parameter processed successfully.',
          'id': data is Map ? data['id'] : null,
          'barcode': data is Map
              ? data['barcode']?.toString() ?? ''
              : '',
          'action': data is Map
              ? data['action']?.toString() ?? ''
              : '',
          'data': data,
        };
      }

      return {
        'code': response['code'] ?? 0,
        'error': false,
        'message': response['message']?.toString() ?? 'Request failed.',
        'id': null,
        'barcode': '',
        'action': '',
        'data': response['data'],
      };
    } catch (e) {
      return {
        'code': 0,
        'error': false,
        'message': e.toString(),
        'id': null,
        'barcode': '',
        'action': '',
        'data': null,
      };
    }
  }



  Map<String, dynamic> toJsonMap() {
    
    return {
      'uid': GlobalVars.userId,
      'selectSupplier': selectSupplier?.id,
      'selectedSeries': selectedSeries?.id,
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
      if (selectSupplier?.state?.id != GlobalVars.placeOfSupplyId) ...{
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
    return ChallanCartStorage.deleteDraftItemById(
      challanType: '${draftType}_$partyId',
      supplierId: partyId,
      draftId: draftId,
    );
  }


  Future<void> delAllDraft() async {
    // delete all data
    // await ChallanCartStorage.clearAll();
  }


  Future<void> getDraftData(String draftName) async {
    final supplier = selectSupplier;

    if (supplier == null) {
      debugPrint('Cannot load draft: no supplier selected');
      return;
    }

    final name = draftName.trim();
    if (name.isEmpty) return;

    // Use the supplied draft name directly for both types.
    final String key = name;

    try {
      chargeData = await extraChargeController.searchOtherCharges('');

      final draftData = await ChallanCartStorage.get(key);

      if (draftData == null) {
        debugPrint('Draft not found: $key');
        notifyListeners();
        return;
      }

      setDraftData(draftData);
      selectedDraft = name;

      if (items.isEmpty) {
        addItem();
      }

      notifyListeners();
      debugPrint('Draft loaded successfully: $key');
    } catch (e, stackTrace) {
      debugPrint('Error loading draft: $e');
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
    }
  }

  void _clearItemsWithoutNotify() {
    for (final item in items) {
      item.dispose();
    }
    items.clear();
  }


  Future deleteCurrentDraft() async {
    await ChallanCartStorage.deleteById(
      key: '${draftType}_${selectSupplier!.id}',
    );
  }

  Future<void> setSupplier(Party? value) async {
    // Save current supplier's working challan before switching.
    if (selectSupplier != null && items.isNotEmpty) {
      await ChallanCartStorage.save(
        toDataMap(),
        key: '${draftType}_${selectSupplier!.id}',
      );
    }

    extraChargeController.delItem();
    _clearItemsWithoutNotify();

    lrNoController.clear();
    lrDateController.clear();
    remarkController.clear();
    finalDiscount = 0;
    additionalDiscountTotal = 0;
    additionalDiscountList = [];
    additionalChargeList = [];
    additionalChargeValue = 0;
    selectedDraft = '';

    selectSupplier = value;

    if (value == null) {
      gstNo = '';
      selectedTransport = null;
      addItem();
      notifyListeners();
      await getProductList('');
      return;
    }

    GlobalVars.supplierCatMargin = value.categoryMargins;

    chargeData = await extraChargeController.searchOtherCharges('');

    final Map<String, dynamic>? savedData = await ChallanCartStorage.get('${draftType}_${selectSupplier!.id}');

    if (savedData != null) {
      setDraftData(savedData);
    }

    gstNo = value.gstNo;

    if (value.transport != null && value.transport!.name.isNotEmpty) {
      selectedTransport = TransportModel(
        id: value.transport!.id,
        transport: value.transport!.name,
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
    await getProductList('');
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
    item.productPrice = 0;
    item.priceController.clear();
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
        print(response);
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
    deleteCurrentDraft();

    notifyListeners();
  }


  Future<void> saveCurrentSupplierData() async {
    if (selectSupplier != null && items.isNotEmpty) {
      await ChallanCartStorage.save(
        toDataMap(),
        key: '${draftType}_${selectSupplier!.id}',
      );
    }
  }

  @override
  void dispose() {
    lrNoController.dispose();
    lrDateController.dispose();
    remarkController.dispose();
    applyDiscountController.dispose();

    for (final item in items) {
      item.dispose();
    }

    items.clear();
    extraChargeController.dispose();

    super.dispose();
  }
}
