import 'package:flutter/material.dart';

import 'extra_charge_model.dart';

class ExtraChargeController extends ChangeNotifier {

  final List<ExtraChargeModel> _items = [];

  List<ExtraChargeModel> get items {
    return List.unmodifiable(_items);
  }

  void addItem() {
    final item = ExtraChargeModel(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
    );
    _items.add(item);
    notifyListeners();
  }

  void updateName(
      String id,
      String value,
      ) {
    final item = _find(id);

    if (item == null) return;

    item.name = value;

    notifyListeners();
  }

  void updateAmount(String id, String value,) {
    final item = _find(id);

    if (item == null) return;
    item.amount = double.tryParse(value) ?? 0;

    notifyListeners();
  }

  void updateTax(
      String id,
      String value,
      ) {
    final item = _find(id);

    if (item == null) return;

    item.taxPercent = double.tryParse(value) ?? 0;

    notifyListeners();
  }


  void updateTaxType(String id, bool isTaxApplicable,) {
    final item = _find(id);

    if (item == null) return;
    if(!isTaxApplicable)
      {
        item.taxController.clear();
        updateTax(
          item.id,
          "0",
        );
      }

    item.isTaxApplicable = isTaxApplicable;

    notifyListeners();
  }

  void updateType(
      String id,
      bool isDiscount,
      ) {
    final item = _find(id);

    if (item == null) return;

    item.isDiscount = isDiscount;
    if(isDiscount==true)
   {
     item.isTaxApplicable = false;
     item.taxPercent = 0.0;
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

    item.dispose();

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

  double get totalCharges {
    return _items
        .where(
          (item) => !item.isDiscount,
    )
        .fold(
      0,
          (sum, item) {
        return sum + item.totalAmount;
      },
    );
  }

  // ============================================================
  // TOTAL EXTRA DISCOUNT
  // ============================================================

  double get totalDiscounts {
    return _items
        .where(
          (item) => item.isDiscount,
    )
        .fold(
      0,
          (sum, item) {
        return sum + item.totalAmount;
      },
    );
  }

  // ============================================================
  // NET EXTRA AMOUNT
  // ============================================================

  double get netAmount {
    return totalCharges - totalDiscounts;
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clear() {
    for (final item in _items) {
      item.dispose();
    }

    _items.clear();

    notifyListeners();
  }

  // ============================================================
  // SET ITEMS
  // ============================================================

  void setItems(
      List<ExtraChargeModel> items,
      ) {
    for (final item in _items) {
      item.dispose();
    }

    _items
      ..clear()
      ..addAll(items);

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _items.clear();
    super.dispose();
  }
}