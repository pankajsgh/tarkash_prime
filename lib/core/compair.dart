
import 'dart:convert';

Map<String, dynamic> getPurchaseChallanChanges({
  required Map<String, dynamic> postData,
  required Map<String, dynamic> fetchedData,
}) {
  const headerFields = <String, String>{
    'selectSupplier': 'supplier_id',
    'selectedSeries': 'series_id',
    'gstNo': 'gst_no',
    'selectedStore': 'store_id',
    'challanNo': 'challan_no',
    'lrNo': 'lr_no',
    'lrDate': 'lr_date',
    'selectedData': 'challan_date',
    'selectedTransport': 'transport_id',
    'selectedAgent': 'agent_id',
    'remark': 'remark',
    'additionalDiscountTotal': 'additional_discount_total',
    'additionalChargeValue': 'additional_charge_value',
    'finalDiscount': 'final_discount',
    'valueOfGood': 'value_of_good',
    'taxableAmount': 'taxable_amount',
    'igst': 'igst',
    'sgst': 'sgst',
    'cgst': 'cgst',
    'grandTotal': 'grand_total',
  };

  const itemFields = <String, String>{
    'productId': 'product_id',
    'amount': 'amount',
    'mrp': 'mrp',
    'b2b': 'b2b',
    'b2c': 'b2c',
    'item_qty': 'item_qty',
    'size': 'size',
    'color': 'color',
    'hsn': 'hsn',
    'barcode': 'barcode',
    'discount_per': 'discount_per',
    'extra_discount': 'extra_discount',
    'extra_charge': 'extra_charge',
    'itemFinalPrice': 'item_final_price',
    'gst': 'gst',
  };
  const chargeFields = <String, String>{
    'name': 'name',
    'amount': 'amount',
    'taxPercent': 'tax_percent',
    'taxType': 'tax_type',
    'isDiscount': 'is_discount',
    'isTaxApplicable': 'is_tax_applicable',
  };

  // Parse JSON strings, numeric strings, and empty values.
  dynamic parseValue(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      final text = value.trim();

      if (text.isEmpty) return null;

      if (text.startsWith('{') || text.startsWith('[')) {
        try {
          return jsonDecode(text);
        } catch (_) {
          return text;
        }
      }

      return num.tryParse(text) ?? text;
    }

    return value;
  }

  // Empty, null, and numeric zero are considered equivalent.
  bool equal(dynamic a, dynamic b) {
    a = parseValue(a);
    b = parseValue(b);

    final aIsEmptyOrZero =
        a == null || (a is num && a == 0);

    final bIsEmptyOrZero =
        b == null || (b is num && b == 0);

    if (aIsEmptyOrZero && bIsEmptyOrZero) {
      return true;
    }

    if (a is num && b is num) {
      return a == b;
    }

    if (a is String && b is String) {
      return a.trim().toLowerCase() == b.trim().toLowerCase();
    }

    return a == b;
  }

  // Read keys with exact or case-insensitive matching.
  dynamic read(Map data, String key) {
    if (data.containsKey(key)) return data[key];

    for (final entry in data.entries) {
      if (entry.key.toString().toLowerCase() == key.toLowerCase()) {
        return entry.value;
      }
    }

    return null;
  }

  // Convert a value into a list, including JSON-encoded lists.
  List<dynamic> getList(dynamic value) {
    value = parseValue(value);
    return value is List ? value : <dynamic>[];
  }

  final changes = <String, dynamic>{};

  // ------------------------------------------------------------
  // HEADER CHANGES
  // ------------------------------------------------------------

  for (final entry in headerFields.entries) {
    final postValue = read(postData, entry.key);
    final fetchedValue = read(fetchedData, entry.value);

    if (!equal(postValue, fetchedValue)) {
      changes[entry.value] = {
        'previous': fetchedValue,
        'current': postValue,
      };
    }
  }

  // ------------------------------------------------------------
  // ITEM CHANGES
  // ------------------------------------------------------------

  final postItems = getList(read(postData, 'items'));
  final fetchedItems = getList(read(fetchedData, 'items'));

  final itemChanges = <Map<String, dynamic>>[];

  final itemCount = postItems.length > fetchedItems.length
      ? postItems.length
      : fetchedItems.length;

  for (var i = 0; i < itemCount; i++) {
    if (i >= fetchedItems.length) {
      itemChanges.add({
        'index': i,
        'change': 'added',
        'current': postItems[i],
      });
      continue;
    }

    if (i >= postItems.length) {
      itemChanges.add({
        'index': i,
        'change': 'removed',
        'previous': fetchedItems[i],
      });
      continue;
    }

    final postItemValue = postItems[i];
    final fetchedItemValue = fetchedItems[i];

    if (postItemValue is! Map || fetchedItemValue is! Map) {
      if (!equal(postItemValue, fetchedItemValue)) {
        itemChanges.add({
          'index': i,
          'change': 'modified',
          'previous': fetchedItemValue,
          'current': postItemValue,
        });
      }
      continue;
    }

    final fieldsChanged = <String, dynamic>{};

    for (final entry in itemFields.entries) {
      final postValue = read(postItemValue, entry.key);
      final fetchedValue = read(fetchedItemValue, entry.value);

      if (!equal(postValue, fetchedValue)) {
        fieldsChanged[entry.value] = {
          'previous': fetchedValue,
          'current': postValue,
        };
      }
    }

    if (fieldsChanged.isNotEmpty) {
      itemChanges.add({
        'index': i,
        'changes': fieldsChanged,
      });
    }
  }

  if (itemChanges.isNotEmpty) {
    changes['items'] = itemChanges;
  }

  // ------------------------------------------------------------
  // EXTRA CHARGE CHANGES
  // Match by name, ignoring database IDs and list order.
  // ------------------------------------------------------------

  final postCharges = getList(read(postData, 'extraCharge'));
  final fetchedCharges = getList(read(fetchedData, 'extraCharge'));

  final chargeChanges = <Map<String, dynamic>>[];
  final usedFetchedIndices = <int>{};

  for (final postChargeValue in postCharges) {
    if (postChargeValue is! Map) continue;

    final postCharge = postChargeValue;
    final postName = read(postCharge, 'name')?.toString().trim() ?? '';

    var matchIndex = -1;

    for (var i = 0; i < fetchedCharges.length; i++) {
      if (usedFetchedIndices.contains(i)) continue;

      final fetchedCharge = fetchedCharges[i];
      if (fetchedCharge is! Map) continue;

      final fetchedName =
          read(fetchedCharge, 'name')?.toString().trim() ?? '';

      if (postName.toLowerCase() == fetchedName.toLowerCase()) {
        matchIndex = i;
        break;
      }
    }

    if (matchIndex == -1) {
      chargeChanges.add({
        'name': postName,
        'change': 'added',
        'current': postCharge,
      });
      continue;
    }

    usedFetchedIndices.add(matchIndex);

    final fetchedCharge = fetchedCharges[matchIndex] as Map;
    final fieldsChanged = <String, dynamic>{};

    for (final entry in chargeFields.entries) {
      final postValue = read(postCharge, entry.key);
      final fetchedValue = read(fetchedCharge, entry.value);

      if (!equal(postValue, fetchedValue)) {
        fieldsChanged[entry.value] = {
          'previous': fetchedValue,
          'current': postValue,
        };
      }
    }

    if (fieldsChanged.isNotEmpty) {
      chargeChanges.add({
        'name': postName,
        'changes': fieldsChanged,
      });
    }
  }

  // Find removed charges.
  for (var i = 0; i < fetchedCharges.length; i++) {
    if (usedFetchedIndices.contains(i)) continue;

    final fetchedCharge = fetchedCharges[i];
    if (fetchedCharge is! Map) continue;

    chargeChanges.add({
      'name': read(fetchedCharge, 'name'),
      'change': 'removed',
      'previous': fetchedCharge,
    });
  }

  if (chargeChanges.isNotEmpty) {
    changes['extraCharge'] = chargeChanges;
  }

  return changes;
}
