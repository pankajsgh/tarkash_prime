import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:calculation_panel/core/network/api_path.dart';
import '../model/stock_report_model.dart';

class StockReportController extends ChangeNotifier {
  StockReportController({Dio? dio}) : _dio = dio ?? Dio() {
    loadStockDetails();
  }

  final Dio _dio;

  final List<StockListModel> _items = [];

  List<StockListModel> get items => List.unmodifiable(_items);

  List<StockListModel> get filteredItems {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) return List.unmodifiable(_items);

    return _items.where((item) {
      if (item.barcode.toLowerCase().contains(query) ||
          item.barcodeId.toLowerCase().contains(query)) {
        return true;
      }

      return item.details.any((detail) {
        return detail.challanNo.toLowerCase().contains(query) ||
            detail.billDate.toLowerCase().contains(query) ||
            detail.storeId.toLowerCase().contains(query);
      });
    }).toList();
  }

  bool isLoading = false;
  String? errorMessage;
  String _search = '';

  String get search => _search;

  int get totalRecords => _items.length;

  double get totalStock =>
      _items.fold(0, (sum, item) => sum + item.totalStocks);

  int get totalEntries =>
      _items.fold(0, (sum, item) => sum + item.details.length);

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> loadStockDetails() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        ApiPath.stockReportList,
      );

      final body = response.data;

      if (body is! Map) {
        throw Exception('Invalid API response.');
      }

      if (body['status'] != true) {
        throw Exception(
          body['message']?.toString() ??
              'Unable to fetch stock details.',
        );
      }

      final rawData = body['data'];

      if (rawData is! List) {
        throw Exception('Stock data format is invalid.');
      }

      final loadedItems = rawData
          .whereType<Map>()
          .map(
            (item) => StockListModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      _items
        ..clear()
        ..addAll(loadedItems);
    } catch (e) {
      errorMessage = e is DioException
          ? (e.response?.data is Map
          ? (e.response?.data['message']?.toString() ??
          'Unable to connect to the server.')
          : 'Unable to connect to the server.')
          : e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadStockDetails();

  String formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2).replaceFirst(
      RegExp(r'0+$'),
      '',
    ).replaceFirst(RegExp(r'\.$'), '');
  }
}
