  import 'dart:convert';
  import 'package:calculation_panel/core/ulitls/utility.dart';
  import 'package:calculation_panel/core/vars/global_vars.dart';
  import 'package:calculation_panel/core/widget/widget_updater.dart';
  import 'package:calculation_panel/core/widget/country_field.dart';
  import 'package:calculation_panel/core/widget/state_field.dart';
  import 'package:calculation_panel/core/widget/lead_source.dart';
  import 'package:flutter/material.dart';
  import '../../../core/database/local_store_manager.dart';
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
  import '../../purchase_challan/model/transport_model.dart';
  import '../model/sale_model.dart';

  class SaleInvoiceController extends ChangeNotifier {
    SaleInvoiceController();

    String draftType = 'sales_invoice';
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
    double additionalDiscountTotal = 0.0;
    List<double> additionalDiscountList = [];
    List<double> additionalChargeList = [];
    final List<SaleItem> items = [];
    int get totalItems => items.length;
    List<ProductModel> products = [];
    String selectedDraft = '';
    RateType? rateType;
    Country? selectedCountry;
    StateData? selectedStateData;
    LeadSource? selectedLeadSource;
    List<OtherChargeModel> chargeData = [];
    VoidCallback? onDraftLoaded;

    String draftListKey(String supplierId) {
      return '${draftType}_draft_$supplierId';
    }

    String draftDataKey(String supplierId, String draftName) {
      return '${draftType}_${supplierId}_${draftName.trim()}';
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

    Future deleteCurrentDraft() async {
      if (selectSupplier != null) {
        await ChallanCartStorage.deleteById(key: selectSupplier!.id);
        await ChallanCartStorage.deleteById(
          key: '${draftType}_${selectSupplier!.id}',
        );
      }
    }

    Future<void> getDraftData(String draftName) async {
      final supplier = selectSupplier;

      if (supplier == null) {
        debugPrint('Cannot load draft: no customer selected');
        return;
      }

      final name = draftName.trim();
      if (name.isEmpty) return;

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

    void setDraftData(Map<String, dynamic> map) {
      extraChargeController.delItem();
      var extraChargeData = map['extraCharge'];
      if (extraChargeData is String) {
        try {
          extraChargeData = jsonDecode(extraChargeData);
        } catch (_) {}
      }
      if (extraChargeData != null && extraChargeData is List && extraChargeData.isNotEmpty) {
        for (var x in extraChargeData) {
          var extraCharges = ExtraChargeItemValue.fromJson(
            Map<String, dynamic>.from(x),
          );
          extraChargeController.setItem(extraCharges, data: chargeData);
        }
        notifyListeners();
      }

      selectSupplier = map['selectSupplier'] != null
          ? (map['selectSupplier'] is Map
              ? Party.fromJson(Map<String, dynamic>.from(map['selectSupplier']))
              : selectSupplier)
          : null;

      gstNo = map['gstNo']?.toString() ?? '';

      selectedStore = map['selectedStore'] != null
          ? (map['selectedStore'] is String
              ? StoreModel(id: map['selectedStore'])
              : StoreModel.fromJson(Map<String, dynamic>.from(map['selectedStore'])))
          : null;

      challanNo = map['challanNo']?.toString() ?? '';
      selectedData = map['selectedData']?.toString() ?? formatDate(DateTime.now());
      lrNoController.text = map['lrNo']?.toString() ?? '';
      lrDateController.text = map['lrDate']?.toString() ?? '';
      remarkController.text = map['remark']?.toString() ?? '';

      var transportData = map['selectedTransport'];
      if (transportData is String) {
        selectedTransport = TransportModel(
          id: transportData,
          transport: '',
          owner: '',
          mobile: '',
          location: '',
          address: '',
        );
      } else if (transportData != null) {
        selectedTransport = TransportModel.fromJson(
          Map<String, dynamic>.from(transportData),
        );
      } else {
        selectedTransport = null;
      }

      var agentData = map['selectedAgent'];
      if (agentData is String) {
        selectedAgent = Agency(id: agentData, name: '');
      } else if (agentData != null) {
        selectedAgent = Agency.fromJson(
          Map<String, dynamic>.from(agentData),
        );
      } else {
        selectedAgent = null;
      }

      additionalDiscountTotal =
          double.tryParse(map['additionalDiscountTotal']?.toString() ?? '') ??
              0.0;

      additionalDiscountList =
          (map['additionalDiscountList'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
              [];

      items.clear();
      var rawItems = map['items'];
      if (rawItems is String) {
        try {
          rawItems = jsonDecode(rawItems);
        } catch (_) {}
      }
      if (rawItems != null && rawItems is List) {
        for (var x in rawItems) {
          if (x is Map) {
            final item = SaleItem.fromJson(Map<String, dynamic>.from(x));
            item.onChanged ?? () => notifyListeners();
            items.add(item);
          }
        }
      }

      additionalChargeValue = double.tryParse(map['additionalChargeValue']?.toString() ?? '') ?? 0.0;

      additionalChargeList =
          (map['additionalChargeList'] as List?)
              ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList() ??
              [];

      rateType = map['rateType'] != null
          ? RateType.fromJson(Map<String, dynamic>.from(map['rateType']))
          : null;

      selectedCountry = map['selectedCountry'] != null
          ? Country.fromJson(Map<String, dynamic>.from(map['selectedCountry']))
          : null;

      selectedStateData = map['selectedStateData'] != null
          ? StateData.fromJson(Map<String, dynamic>.from(map['selectedStateData']))
          : null;

      selectedLeadSource = map['selectedLeadSource'] != null
          ? LeadSource.fromJson(Map<String, dynamic>.from(map['selectedLeadSource']))
          : null;

      finalDiscount = double.tryParse(map['finalDiscount']?.toString() ?? '') ?? 0;
      notifyListeners();
      onDraftLoaded?.call();
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
        'selectedCountry': selectedCountry?.toJson(),
        'selectedStateData': selectedStateData?.toJson(),
        'selectedLeadSource': selectedLeadSource?.toJson(),
        'additionalDiscountTotal': additionalDiscountTotal,
        'additionalDiscountList': additionalDiscountList,
        'additionalChargeList': additionalChargeList,
        'rateType': rateType?.toJson(),
        'items': items
            .where(
              (e) =>
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

    Map<String, dynamic> toJsonMap() {
      final isInterState = selectSupplier != null &&
          selectSupplier!.state != null &&
          selectSupplier!.state!.id != GlobalVars.placeOfSupplyId;

      return {
        'uid': GlobalVars.userId,
        'selectSupplier': selectSupplier?.id ?? '',
        'gstNo': gstNo,
        'selectedStore': selectedStore?.id ?? '',
        'challanNo': challanNo,
        'selectedData': selectedData,
        'lrNo': lrNoController.text,
        'lrDate': lrDateController.text,
        'remark': remarkController.text,
        'selectedTransport': selectedTransport?.id ?? '',
        'selectedAgent': selectedAgent?.id ?? '',
        'additionalDiscountTotal': additionalDiscountTotal.toString(),
        'items': jsonEncode(items
            .where((e) => e.product != null && e.product!.name.isNotEmpty)
            .map((e) => e.toJsonApi())
            .toList()),
        'additionalChargeValue': additionalChargeValue.toString(),
        'extraCharge': jsonEncode(extraChargeController.items
            .where((e) => e.itemValue.amount > 0)
            .map((e) => e.toDataMap())
            .toList()),
        'finalDiscount': finalDiscount.toString(),
        'valueOfGood': getTotalGoodsValue.toString(),
        'taxableDiscount': valueOfTaxableGoods().toString(),
        if (isInterState) ...{
          'igst': igst.toStringAsFixed(2),
          'sgst': '',
          'cgst': '',
        } else ...{
          'igst': '',
          'sgst': sgst.toStringAsFixed(2),
          'cgst': cgst.toStringAsFixed(2),
        },
        'grandTotal': grandTotal.toStringAsFixed(2),
      };
    }

    Future<bool> saveDraft() async {
      if (selectSupplier == null || selectSupplier!.id.isEmpty) {
        showMessage('Please select a customer first', ToastType.info);
        return false;
      }
      await ChallanCartStorage.save(toDataMap(), key: selectSupplier!.id);
      showMessage('Draft saved successfully', ToastType.success);
      return true;
    }

    Future<bool> submitSaleInvoice({bool isEdit = false}) async {
      if (selectSupplier == null) {
        showMessage('Please select a customer', ToastType.error);
        return false;
      }

      if (items.isEmpty) {
        showMessage('No products added', ToastType.error);
        return false;
      }

      isSubmitting = true;
      notifyListeners();
      updateSummery.update();

      try {
        final requestBody = toJsonMap();
        if (isEdit) {
          requestBody['id'] = updateId;
        }

        final response = await ApiProvider.createServerRequest(
          apiUrl: ApiPath.urlSaleInvoice,
          requestBody: requestBody,
          isFormData: true,
        );

        isSubmitting = false;
        notifyListeners();
        updateSummery.update();

        if (response['error'] != null && response['error'] == true) {
          showMessage(response['msg'] ?? 'Sale Invoice submitted successfully', ToastType.success);
          await deleteCurrentDraft();
          clearAll();
          return true;
        } else {
          showMessage(response['msg'] ?? 'Failed to submit Sale Invoice', ToastType.error);
          return false;
        }
      } catch (e) {
        isSubmitting = false;
        notifyListeners();
        updateSummery.update();
        showMessage('Submission error: $e', ToastType.error);
        return false;
      }
    }

    void update() {
      notifyListeners();
    }

    Future<void> setSupplier(Party? value) async {
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
        getProductList('');
        return;
      }

      chargeData = await extraChargeController.searchOtherCharges('');

      final Map<String, dynamic>? savedData =
          await ChallanCartStorage.get(value.id) ??
          await ChallanCartStorage.get('${draftType}_${value.id}');

      if (savedData != null) {
        setDraftData(savedData);
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

    void _clearItemsWithoutNotify() {
      for (final item in items) {
        item.dispose();
      }
      items.clear();
    }

    void setStore(dynamic store) {
      if (store is StoreModel) {
        selectedStore = store;
      } else if (store != null) {
        selectedStore = StoreModel(
          id: store.id,
          store: store.store,
          shortName: store.shortName,
        );
      } else {
        selectedStore = null;
      }
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
