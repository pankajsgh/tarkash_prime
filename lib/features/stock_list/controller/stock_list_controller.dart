
import 'package:calculation_panel/core/network/api_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/stock_list_model.dart';

class StockListController extends ChangeNotifier {
  StockListController({Dio? dio}) : _dio = dio ?? Dio() {
    loadStockDetails();
  }

  final Dio _dio;

  List<StockDetailsModel> _items = [];

  bool isLoading = false;
  String errorMessage = '';
  String searchQuery = '';
  bool _disposed = false;

  List<StockDetailsModel> get items => _items;

  List<StockDetailsModel> get filteredItems {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return _items;

    return _items.where((item) {
      return item.barcode.toLowerCase().contains(query) ||
          item.challanNo.toLowerCase().contains(query) ||
          item.challanId.toLowerCase().contains(query) ||
          item.storeId.toLowerCase().contains(query) ||
          item.barcodeId.toLowerCase().contains(query);
    }).toList();
  }

  int get totalRecords => _items.length;

  double get totalStock {
    return _items.fold<double>(
      0,
          (total, item) => total + (double.tryParse(item.stocks) ?? 0),
    );
  }

  void setSearch(String value) {
    searchQuery = value;
    _notify();
  }

  Future<void> loadStockDetails({bool showLoader = true}) async {
    if (showLoader) {
      isLoading = true;
      errorMessage = '';
      _notify();
    }

    try {
      final response = await _dio.get(
        ApiPath.stockListApi,
        options: Options(
          responseType: ResponseType.json,
          headers: {'Accept': 'application/json'},
        ),
      );

      final responseData = response.data;

      if (responseData is! Map) {
        throw Exception('Invalid API response');
      }

      final body = Map<String, dynamic>.from(responseData);
      final success = body['status'] == true ||
          body['status']?.toString().toLowerCase() == 'true' ||
          body['status']?.toString() == '1';

      if (!success) {
        throw Exception(
          body['message']?.toString() ?? 'Unable to load stock details',
        );
      }

      final rawData = body['data'];

      if (rawData is! List) {
        throw Exception('Stock data is not a valid list');
      }

      _items = rawData
          .whereType<Map>()
          .map(
            (item) => StockDetailsModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      errorMessage = '';
    } on DioException catch (e) {
      errorMessage = _readDioError(e);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      _notify();
    }
  }

  String _readDioError(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return e.message ?? 'Unable to connect to the server';
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
