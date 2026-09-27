import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/database/sql_databaes/extra_charge_database.dart';
import '../../../core/network/api_path.dart';
import '../../../core/network/api_repository.dart';
import '../../../core/vars/global_vars.dart';
import '../../../core/widget/widget_updater.dart';
import '../../other_charges/data/model/other_charge_model.dart';
import '../model/extra_charge_model.dart';

class ExtraChargeController extends ChangeNotifier {

  final List<ExtraChargeModel> _items = [];

  List<ExtraChargeModel> get items {
    return List.unmodifiable(_items);
  }

  final WidgetUpdater updateCharges = WidgetUpdater();

  List<OtherChargeModel> searchCharges = [];

  Future<List<OtherChargeModel>> searchOtherCharges(String search) async
  {
    try {
      final query = search.trim();

      final Map<String, String> formData = {
        'search': query,
      };
      //
      // final responseData =
      // await ApiProvider.createServerRequest(
      //   apiUrl: ApiPath.searchOtherCharges,
      //   requestBody: formData,
      //   isFormData: true,
      // );

      var responseData = {};

      if(GlobalVars.isOffline)
      {
        final List<Map<String, dynamic>> charges =
        await ExtraChargeDatabase.instance.search(query);
        responseData = {
          'status': true,
          'data':charges
        };
      }

// ----------------------------------------------------------------------
// RESPONSE
// ----------------------------------------------------------------------

      if (responseData['status'] == true) {
        final data =
            (responseData['data'] as List?)
                ?.map(
                  (item) =>
                  OtherChargeModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
            )
                .toList() ??
                [];

        searchCharges = data;

        updateCharges.update();

        return data;
      }

      searchCharges = [];

      updateCharges.update();

      return [];
    } on DioException catch (e) {
      debugPrint(
        'Search Other Charges Dio Error: ${e.message}',
      );

      debugPrint(
        'Response: ${e.response?.data}',
      );

      return [];
    } catch (e) {
      debugPrint(
        'Search Other Charges Error: $e',
      );

      return [];
    }
  }

  void setCharge(OtherChargeModel? value, ExtraChargeModel item) {
    if (value == null) {
      item.selectChargeName = null;
      item.itemValue = ExtraChargeItemValue(id: '' );
      updateAmount(item.id, '0',);
      notifyListeners();
      return;
    }

    if(value.chargeNature=='Deduction')
      {
        item.itemValue.isDiscount = true;
      } else {
      item.itemValue.isDiscount = false;
    }

    if(value.calculationType!='Amount')
      {
        item.itemValue.isItemQty = true;
      }

    item.itemValue.itemWiseDistribution = value.calculationType;
    item.id = value.id;
    item.itemValue.id = value.id;
    item.itemValue.name = value.chargeName;
    item.itemValue.amount = double.tryParse(value.defaultValue)?? 0;
    item.selectChargeName = value;
    item.itemValue.taxType = value.appliedOn;
    if(item.itemValue.taxType=="Separate")
      {
        item.itemValue.isTaxApplicable = true;
        item.itemValue.taxPercent = double.tryParse(value.hsnTax) ?? 0;
      }
    updateAmount(item.id, value.defaultValue);
    notifyListeners();
  }


  void addItem() {

    final item = ExtraChargeModel(
      id: '',
      itemValue: ExtraChargeItemValue(id: ''),
    );
    _items.add(item);
    notifyListeners();
  }

 void setItem(ExtraChargeItemValue value, {required List<OtherChargeModel> data}) {

    bool isSet = false;
    if(value.id.isNotEmpty){
      for(var x in data)
        {

          if(value.id==x.id)
            {

              _items.add(ExtraChargeModel(id: x.id, selectChargeName: x, itemValue: value));
              isSet = true;
            }
        }
    }
    if(!isSet) {
      _items.add(ExtraChargeModel(id:value.id, selectChargeName: OtherChargeModel(chargeName: value.name, id: '', chargeType: '', chargeNature: '', printName: '', defaultValue: '', calculationType: value.itemWiseDistribution, appliedOn: '', distributionMethod: '', hsn: '', hsnTax: '', allowManualChange: '', isActive: '', createdAt: '', updatedAt: ''), itemValue: value));
    }
 }

  void delItem(){
    _items.clear();
  }

  void updateName(
      String id,
      String value,
      ) {
    final item = _find(id);

    if (item == null) return;

    item.itemValue.name = value;

    notifyListeners();
  }

  void updateAmount(String id, String value,) {
    final item = _find(id);
    if (item == null) return;
    item.itemValue.amount = double.tryParse(value) ?? 0;
    notifyListeners();
  }

  void updateTax(
      String id,
      String value,
      ) {
    final item = _find(id);

    if (item == null) return;

    item.itemValue.taxPercent = double.tryParse(value) ?? 0;

    notifyListeners();
  }


  void updateTaxType(String id, bool isTaxApplicable,) {
    final item = _find(id);

    if (item == null) return;
    if(!isTaxApplicable)
      {
        updateTax(
          item.id,
          "0",
        );
      }

    item.itemValue.isTaxApplicable = isTaxApplicable;

    notifyListeners();
  }

  void updateType(
      String id,
      bool isDiscount,
      ) {
    final item = _find(id);

    if (item == null) return;

    item.itemValue.isDiscount = isDiscount;
    if(isDiscount==true)
   {
     item.itemValue.isTaxApplicable = false;
     item.itemValue.taxPercent = 0.0;
     item.taxAmount = 0.0;
   }
    notifyListeners();
  }


  void deleteItem(
      String id,
      ) {
    final index = _items.indexWhere(
          (item) => item.id == id,
    );
    if (index == -1) return;
    final item = _items.removeAt(index);
    notifyListeners();
  }

  // ============================================================
  // FIND
  // ============================================================

  ExtraChargeModel? _find(
      String id,
      ) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  // ============================================================
  // TAX TOTAL
  // ============================================================

  double get totalTax {
    return _items.fold(
      0,
          (sum, item) {
        return sum + item.taxAmount;
      },
    );
  }

  // ============================================================
  // TOTAL EXTRA CHARGES
  // ============================================================
  //
  double get totalCharges {
    return _items
        .where(
          (item) => !item.itemValue.isDiscount,
    )
        .fold(
      0,
          (sum, item) {
        return sum + item.totalAmount;
      },
    );
  }

  List<double> discountListsByCat() {
    if(items.isEmpty) {
      return [];
    }
    List<List<double>> lists = items.map((e)=>e.discountList).toList();
    final length = lists.first.length;
    return List.generate(
      length,
          (index) => lists.fold(
        0.0,
            (sum, list) =>
        sum + (index < list.length ? (list[index] ?? 0.0) : 0.0),
      ),
    );
  }

  List<double> totalChargeListsByCat() {
    if(items.isEmpty) {
      return [];
    }
    List<List<double>> lists = items.map((e)=>e.chargeList).toList();
    final length = lists.first.length;
    return List.generate(
      length,
          (index) => lists.fold(
        0.0,
            (sum, list) =>
        sum + (index < list.length ? (list[index] ?? 0.0) : 0.0),
      ),
    );
  }

  // ============================================================
  // TOTAL EXTRA DISCOUNT
  // ============================================================

  double get totalDiscounts {
    return _items
        .where(
          (item) => item.itemValue.isDiscount,
    )
        .fold(
      0,
          (sum, item) {
        return sum + item.totalAmount;
      },
    );
  }


  double get totalDiscountsWithOutFinal {
    double total = 0.0;
    for (final item in _items) {
      if (item.itemValue.isDiscount && item.itemValue.taxType != 'Final Bill') {
        total += item.totalAmount;
      }
    }
    return total;
  }

  double get totalDiscountsWithFinal {
    double total = 0.0;
    for (final item in _items) {
      if (item.itemValue.isDiscount && item.itemValue.taxType == 'Final Bill') {
        total += item.totalAmount;
      }
    }
    return total;
  }


  void clear() {
    _items.clear();
    notifyListeners();
  }


  Map<String, dynamic>toMap(){
    return {
      'items': items.map((e)=>e.toDataMap()).toList()
    };
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _items.clear();
    super.dispose();
  }
}