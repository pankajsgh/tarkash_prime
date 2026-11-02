
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_path.dart';
import '../model/product_parm_model.dart';

class ProductParameterController extends ChangeNotifier {
  final Dio dio;

  ProductParameterController({
    required this.dio,
    String productId = '',
  }) : _productId = productId.trim();

  static const int pageSize = 20;

  String _productId;
  String get productId => _productId;

  final List<ProductParameterModel> _items = [];

  List<ProductParameterModel> get items =>
      List.unmodifiable(_items);

  String _search = '';
  String get search => _search;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  int limit = 0;
  int total = 0;

  String? errorMessage;
  int _requestGeneration = 0;

  List<ProductParameterModel> get filteredItems {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) {
      return List.unmodifiable(_items);
    }

    return _items.where((item) {
      return [
        item.id,
        item.productId,
        item.productName,
        item.sizeId,
        item.colorId,
        item.barcode,
        item.purchasePrice,
        item.b2bPrice,
        item.b2cPrice,
        item.mrp,
        item.status,
      ].any((value) => value.toLowerCase().contains(query));
    }).toList(growable: false);
  }

  // Switch between a single product and all products.
  Future<void> setProductFilter(String productId) async {
    final nextId = productId.trim();

    if (_productId == nextId) {
      if (_items.isEmpty && !isLoading) {
        await refresh();
      }
      return;
    }

    _productId = nextId;

    // Invalidate any request belonging to the previous filter.
    _requestGeneration++;

    _items.clear();
    limit = 0;
    total = 0;
    hasMore = true;
    errorMessage = null;
    isLoading = false;
    isLoadingMore = false;

    notifyListeners();

    await fetchProductParameters();
  }

  Future<void> showAllProducts() => setProductFilter('');

  Future<void> fetchProductParameters({
    bool refresh = false,
  }) async {
    if (refresh) {
      _requestGeneration++;
      _items.clear();
      limit = 0;
      total = 0;
      hasMore = true;
      errorMessage = null;
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }

    if (isLoading || isLoadingMore || !hasMore) return;

    final generation = _requestGeneration;
    final requestOffset = limit;
    final requestProductId = _productId;

    if (requestOffset == 0) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }

    errorMessage = null;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        if (requestProductId.isNotEmpty)
          'product_id': requestProductId,
        'limit': requestOffset.toString(),
      });

      final response = await dio.post(
        ApiPath.productParmList,
        data: formData,
      );

      // Ignore responses from an old filter or refresh.
      if (generation != _requestGeneration) return;

      dynamic body = response.data;

      if (body is String) {
        body = jsonDecode(body);
      }

      if (body is! Map || body['code']?.toString() != '1') {
        throw Exception(
          body is Map
              ? body['message']?.toString() ??
              'Failed to load product parameters'
              : 'Invalid API response',
        );
      }

      final rawRows = body['data'];
      final rows = rawRows is List ? rawRows : <dynamic>[];

      final existingIds = _items.map((e) => e.id).toSet();
      var addedCount = 0;

      for (final row in rows) {
        if (row is! Map) continue;

        final item = ProductParameterModel.fromJson(
          Map<String, dynamic>.from(row),
        );

        if (item.id.isEmpty || existingIds.contains(item.id)) {
          continue;
        }

        _items.add(item);
        existingIds.add(item.id);
        addedCount++;
      }

      final pagination = body['pagination'];

      if (pagination is Map) {
        total = int.tryParse(
          pagination['total']?.toString() ?? '',
        ) ??
            total;

        hasMore = pagination['has_more'] == true;

        final nextOffset = pagination['next_limit'];

        if (hasMore && nextOffset != null) {
          limit = int.tryParse(nextOffset.toString()) ??
              (requestOffset + rows.length);
        } else if (!hasMore) {
          limit = requestOffset + rows.length;
        }
      } else {
        limit = requestOffset + rows.length;
        total = _items.length;
        hasMore = rows.length >= pageSize && addedCount > 0;
      }

      if (rows.isEmpty || addedCount == 0) {
        hasMore = false;
      }
    } catch (e) {
      if (generation == _requestGeneration) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      if (generation == _requestGeneration) {
        isLoading = false;
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;
    await fetchProductParameters();
  }

  Future<void> refresh() async {
    await fetchProductParameters(refresh: true);
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void clearSearch() {
    _search = '';
    notifyListeners();
  }

  void updateItem(ProductParameterModel updatedItem) {
    final index = _items.indexWhere(
          (item) => item.id == updatedItem.id,
    );

    if (index == -1) return;

    _items[index] = updatedItem;
    notifyListeners();
  }
}
