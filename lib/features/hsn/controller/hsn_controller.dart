import 'dart:convert';
import 'package:calculation_panel/core/network/api_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../model/hsn_tax_slab.dart';

class HsnController extends ChangeNotifier {

  HsnController({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  final List<HsnModelItem> _hsnList = [];

  String _searchText = '';
  HsnModelItem? _selectedHsn;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<HsnModelItem> get hsnList => List.unmodifiable(_hsnList);

  HsnModelItem? get selectedHsn => _selectedHsn;

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  List<HsnModelItem> get filteredList {
    final query = _searchText.toLowerCase().trim();

    if (query.isEmpty) {
      return List.unmodifiable(_hsnList);
    }

    return _hsnList.where((item) {
      return item.hsncode.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query);
    }).toList();
  }

  int get totalSlabs => _hsnList.fold(
    0,
        (total, item) => total + item.hsnTaxSlabs.length,
  );

  int get missingSlabs =>
      _hsnList.where((item) => item.hsnTaxSlabs.isEmpty).length;

// ------------------------------------------------------------
// RESPONSE HELPER
// ------------------------------------------------------------

  dynamic _decodeResponse(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }

    return data;
  }

  String _responseMessage(dynamic decoded, String fallback) {
    if (decoded is Map) {
      return decoded['message']?.toString() ??
          decoded['msg']?.toString() ??
          fallback;
    }

    return fallback;
  }

// ------------------------------------------------------------
// FETCH HSN LIST
// ------------------------------------------------------------

  Future<void> fetchHsnList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio
          .get(
        ApiPath.getHsnList,
        options: Options(
          headers: {'Accept': 'application/json'},
          responseType: ResponseType.json,
        ),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(
          'Unable to load HSN list. HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded = _decodeResponse(response.data);

      final List<dynamic> jsonList;

      if (decoded is List) {
        jsonList = decoded;
      } else if (decoded is Map) {
        if (decoded['code'] != null &&
            decoded['code'].toString() != '1') {
          throw Exception(
            _responseMessage(decoded, 'Failed to fetch HSN list.'),
          );
        }

        final data = decoded['HSNList'] ?? decoded['data'];

        if (data is! List) {
          throw const FormatException(
            'Invalid API response: HSNList was not found.',
          );
        }

        jsonList = data;
      } else {
        throw const FormatException(
          'Invalid JSON response from HSN API.',
        );
      }

      final items = jsonList.map((json) {
        if (json is! Map) {
          throw const FormatException('Invalid HSN record.');
        }

        return HsnModelItem.fromJson(
          Map<String, dynamic>.from(json),
        );
      }).toList();

      final previousId = _selectedHsn?.id;

      _hsnList
        ..clear()
        ..addAll(items);

      HsnModelItem? selected;

      for (final item in _hsnList) {
        if (item.id == previousId) {
          selected = item;
          break;
        }
      }

      _selectedHsn = selected ??
          (_hsnList.isNotEmpty ? _hsnList.first : null);
    } on DioException catch (e) {
      _errorMessage = e.response?.data is Map
          ? _responseMessage(
        e.response!.data,
        e.message ?? 'Unable to load HSN list.',
      )
          : e.message ?? 'Unable to load HSN list.';
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// ------------------------------------------------------------
// SEARCH AND SELECTION
// ------------------------------------------------------------

  void search(String value) {
    _searchText = value;
    notifyListeners();
  }

  void selectHsn(HsnModelItem item) {
    _selectedHsn = item;
    notifyListeners();
  }

// ------------------------------------------------------------
// ADD TAX SLAB
// ------------------------------------------------------------

  void addSlab({
    required double priceFrom,
    required double priceTo,
    required double tax,
    required String date,
  }) {
    if (_selectedHsn == null ||
        priceFrom < 0 ||
        priceTo < priceFrom ||
        tax < 0 ||
        tax > 100) {
      return;
    }

    _selectedHsn!.hsnTaxSlabs.add(
      HsnTaxSlabModel(
        priceFrom: priceFrom,
        priceTo: priceTo,
        tax: tax,
        slabsDate: date,
      ),
    );

    _selectedHsn!.hsnTaxSlabs.sort(
          (a, b) => a.priceFrom.compareTo(b.priceFrom),
    );

    _errorMessage = null;
    notifyListeners();
  }

// ------------------------------------------------------------
// UPDATE TAX SLAB
// ------------------------------------------------------------

  void updateSlab(
      HsnTaxSlabModel slab, {
        required double priceFrom,
        required double priceTo,
        required double tax,
        required String date,
      }) {
    if (priceFrom < 0 ||
        priceTo < priceFrom ||
        tax < 0 ||
        tax > 100) {
      return;
    }

    slab
      ..priceFrom = priceFrom
      ..priceTo = priceTo
      ..tax = tax
      ..slabsDate = date;

    _selectedHsn?.hsnTaxSlabs.sort(
          (a, b) => a.priceFrom.compareTo(b.priceFrom),
    );

    _errorMessage = null;
    notifyListeners();
  }

// ------------------------------------------------------------
// DELETE TAX SLAB
// ------------------------------------------------------------

  void deleteSlab(HsnTaxSlabModel slab) {
    _selectedHsn?.hsnTaxSlabs.remove(slab);
    _errorMessage = null;
    notifyListeners();
  }

// ------------------------------------------------------------
// CREATE NEW HSN
//
// Add this to ApiPath if it does not already exist:
// static const String createHsn =
//     'http://localhost/gobuzy_prime/api/hsn_create.php';
// ------------------------------------------------------------

  Future<bool> createHsn(String hsnCode) async {
    final code = hsnCode.trim();

    if (code.isEmpty) {
      _errorMessage = 'Please enter an HSN code.';
      notifyListeners();
      return false;
    }

    final alreadyExists = _hsnList.any(
          (item) => item.hsncode.trim().toLowerCase() == code.toLowerCase(),
    );

    if (alreadyExists) {
      _errorMessage = 'This HSN code already exists.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio
          .post(
        ApiPath.createHsn,
        data: FormData.fromMap({
          'hsncode': code,
        }),
        options: Options(
          headers: {'Accept': 'application/json'},
          responseType: ResponseType.json,
        ),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
          'Failed to create HSN. HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded = _decodeResponse(response.data);

      if (decoded is! Map) {
        throw const FormatException(
          'Invalid create HSN response from server.',
        );
      }

      if (decoded['code'].toString() != '1') {
        throw Exception(
          _responseMessage(decoded, 'Unable to create HSN.'),
        );
      }

// Reload the HSN list from the database.
      await fetchHsnList();

      if (_errorMessage != null) {
        throw Exception(
          'HSN created, but refreshing the list failed: $_errorMessage',
        );
      }

// Select the newly created HSN.
      final responseData = decoded['data'];

      String? newId;
      if (responseData is Map) {
        newId = responseData['id']?.toString();
      }

      HsnModelItem? createdItem;

      for (final item in _hsnList) {
        if ((newId != null && item.id == newId) ||
            item.hsncode.trim().toLowerCase() == code.toLowerCase()) {
          createdItem = item;
          break;
        }
      }

      if (createdItem != null) {
        _selectedHsn = createdItem;
      }

      _errorMessage = null;
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data is Map
          ? _responseMessage(
        e.response!.data,
        e.message ?? 'Unable to create HSN.',
      )
          : e.message ?? 'Unable to create HSN.';
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

// ------------------------------------------------------------
// SAVE TAX SLABS
//
// PHP API replaces all existing slabs for the selected HSN
// with the submitted HSNTaxSlab list.
// ------------------------------------------------------------

  Future<bool> saveTaxSlabs() async {
    final selected = _selectedHsn;

    if (selected == null) {
      _errorMessage = 'Please select an HSN record.';
      notifyListeners();
      return false;
    }

    if (selected.hsnTaxSlabs.isEmpty) {
      _errorMessage = 'Add at least one tax slab before saving.';
      notifyListeners();
      return false;
    }

    for (final slab in selected.hsnTaxSlabs) {
      if (slab.priceFrom < 0 ||
          slab.priceTo < slab.priceFrom ||
          slab.tax < 0 ||
          slab.tax > 100) {
        _errorMessage = 'Please check the price ranges and tax rates.';
        notifyListeners();
        return false;
      }
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final slabList = selected.hsnTaxSlabs.map((slab) {
        return <String, String>{
          'PriceFrom': slab.priceFrom.toString(),
          'PriceTo': slab.priceTo.toString(),
          'Tax': slab.tax.toString(),
          'SlabsDate': _toApiDate(slab.slabsDate),
        };
      }).toList();

      final response = await _dio
          .post(
        ApiPath.getHsnUpdateList,
        data: FormData.fromMap({
          'hsn_id': selected.id,
          'HSNTaxSlab': jsonEncode(slabList),
        }),
        options: Options(
          headers: {'Accept': 'application/json'},
          responseType: ResponseType.json,
        ),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
          'Save failed. HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded = _decodeResponse(response.data);

      if (decoded is! Map) {
        throw const FormatException(
          'Invalid save response from server.',
        );
      }

      if (decoded['code'].toString() != '1') {
        throw Exception(
          _responseMessage(decoded, 'Unable to save tax slabs.'),
        );
      }

// Refresh data after saving.
      await fetchHsnList();

      if (_errorMessage != null) {
        throw Exception(
          'Saved successfully, but refreshing the HSN list failed: '
              '$_errorMessage',
        );
      }

      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data is Map
          ? _responseMessage(
        e.response!.data,
        e.message ?? 'Unable to save tax slabs.',
      )
          : e.message ?? 'Unable to save tax slabs.';
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

// ------------------------------------------------------------
// DATE CONVERSION
// ------------------------------------------------------------

  String _toApiDate(String value) {
    final date = value.trim();

    if (date.isEmpty) {
      final now = DateTime.now();

      return '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
    }

// Already yyyy-MM-dd.
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      return date;
    }

// Convert dd/MM/yyyy to yyyy-MM-dd.
    final parts = date.split('/');

    if (parts.length == 3 && parts[2].length == 4) {
      return '${parts[2]}-'
          '${parts[1].padLeft(2, '0')}-'
          '${parts[0].padLeft(2, '0')}';
    }

    return date;
  }
}
