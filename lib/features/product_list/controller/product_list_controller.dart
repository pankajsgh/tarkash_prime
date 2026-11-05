import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/network/api_path.dart';
import '../../../../core/network/api_repository.dart';
import '../../purchase_challan/model/product_model.dart';

class ProductListController extends ChangeNotifier {
  // ============================================================
  // CONSTANTS
  // ============================================================

  static const int resultLimit = 20;
  String supplierId = '';
  String billDate = '';

  static const Duration searchDebounceDuration = Duration(milliseconds: 500);

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController searchController = TextEditingController();

  Timer? _searchDebounce;

  // ============================================================
  // DATA
  // ============================================================

  List<ProductModelItem> products = [];

  // ============================================================
  // LOADING
  // ============================================================

  bool isLoading = false;

  bool isLoadingMore = false;

  bool isDeleting = false;

  // ============================================================
  // ERROR
  // ============================================================

  String errorMessage = '';

  // ============================================================
  // PAGINATION
  // ============================================================

  int offset = 0;

  int totalData = 0;

  // ============================================================
  // GETTERS
  // ============================================================

  void setSupplier(String value){
    supplierId = value;
  }
  void setBillDate(String value){
    billDate = value;
  }

  bool get hasMore {
    return products.length < totalData;
  }

  int get showingCount {
    return products.length;
  }

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  ProductListController() {
    searchController.addListener(
      _onSearchChanged,
    );
  }

  // ============================================================
  // SEARCH CHANGE
  // ============================================================

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      searchDebounceDuration,
          () {
        fetchProducts(
          refresh: true,
        );
      },
    );

    notifyListeners();
  }

  // ============================================================
  // FETCH PRODUCTS
  // ============================================================

  Future<void> fetchProducts({
    bool refresh = false,
  }) async {
    // ----------------------------------------------------------
    // DUPLICATE REQUEST PROTECTION
    // ----------------------------------------------------------

    if (isLoading || isLoadingMore) {
      return;
    }

    // ----------------------------------------------------------
    // REFRESH
    // ----------------------------------------------------------

    if (refresh) {
      _resetPagination();

      isLoading = true;

      notifyListeners();
    }

    // ----------------------------------------------------------
    // LOAD MORE
    // ----------------------------------------------------------

    else {
      if (!hasMore) {
        return;
      }

      isLoadingMore = true;

      notifyListeners();
    }

    try {
      // ========================================================
      // REQUEST BODY
      // ========================================================

      final Map<String, String> requestBody = {
        'SupplierId': supplierId,
        'BillDate': '',
        'search': searchController.text.trim(),
        'limit': resultLimit.toString(),
      };

      _printRequest(
        requestBody,
      );

      // ========================================================
      // API REQUEST
      // ========================================================

      final response =
      await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getProductList,
        requestBody: requestBody,
        isFormData: true,
      );

      debugPrint(
        'Product List Response: $response',
      );



      // ========================================================
      // PARSE RESPONSE
      // ========================================================

      final data = ProductListModel.fromJson(
        Map<String, dynamic>.from(
          response,
        ),
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (data.code == 1 && data.error == true) {
        _handleSuccess(
          data: data,
          refresh: refresh,
        );

        return;
      }

      // ========================================================
      // API ERROR
      // ========================================================

      errorMessage =
          data.msg ??
              response['msg']?.toString() ??
              'Unable to load products.';
    } catch (e, stackTrace) {
      errorMessage = 'Something went wrong: $e';

      debugPrint(
        'Product List Error: $e',
      );

      debugPrint(
        'Product List StackTrace: $stackTrace',
      );
    } finally {
      isLoading = false;
      isLoadingMore = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SUCCESS HANDLER
  // ============================================================

  void _handleSuccess({
    required ProductListModel data,
    required bool refresh,
  }) {
    // ----------------------------------------------------------
    // TOTAL COUNT
    // ----------------------------------------------------------

    totalData =
        int.tryParse(
          data.totalData ?? '0',
        ) ??
            0;

    // ----------------------------------------------------------
    // API ITEMS
    // ----------------------------------------------------------

    final List<ProductModelItem> newProducts =
    List<ProductModelItem>.from(
      data.productList,
    );

    // ----------------------------------------------------------
    // REFRESH
    // ----------------------------------------------------------

    if (refresh) {
      products = newProducts;
    }

    // ----------------------------------------------------------
    // LOAD MORE
    // ----------------------------------------------------------

    else {
      products.addAll(
        newProducts,
      );
    }

    // ----------------------------------------------------------
    // UPDATE OFFSET
    // ----------------------------------------------------------

    offset += newProducts.length;

    // ----------------------------------------------------------
    // CLEAR ERROR
    // ----------------------------------------------------------

    errorMessage = '';

    // ----------------------------------------------------------
    // DEBUG
    // ----------------------------------------------------------

    debugPrint(
      '================================================',
    );

    debugPrint(
      'Product List Success',
    );

    debugPrint(
      'Received: ${newProducts.length}',
    );

    debugPrint(
      'Current Products: ${products.length}',
    );

    debugPrint(
      'Total Products: $totalData',
    );

    debugPrint(
      'Next Offset: $offset',
    );

    debugPrint(
      'Has More: $hasMore',
    );

    debugPrint(
      '================================================',
    );
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<bool> deleteProduct({
    required String productId,
  }) async {
    // ----------------------------------------------------------
    // DUPLICATE DELETE PROTECTION
    // ----------------------------------------------------------

    if (isDeleting) {
      return false;
    }

    isDeleting = true;

    errorMessage = '';

    notifyListeners();

    try {
      // ========================================================
      // REQUEST BODY
      // ========================================================

      final Map<String, String> requestBody = {
        'id': productId,
      };

      // ========================================================
      // DEBUG REQUEST
      // ========================================================

      debugPrint(
        '================================================',
      );

      debugPrint(
        'Delete Product Request',
      );

      debugPrint(
        'URL: ${ApiPath.deleteProductApi}',
      );

      debugPrint(
        'BODY: $requestBody',
      );

      debugPrint(
        '================================================',
      );

      // ========================================================
      // API REQUEST
      // ========================================================

      final response =
      await ApiProvider.createServerRequest(
        apiUrl: ApiPath.deleteProductApi,
        requestBody: requestBody,
        isFormData: true,
      );

      // ========================================================
      // DEBUG RESPONSE
      // ========================================================

      debugPrint(
        'Delete Product Response: $response',
      );


      // ========================================================
      // API SUCCESS
      // ========================================================

      final dynamic code = response['code'];

      final dynamic error = response['error'];

      if (code == 200 && error == true) {
        // ------------------------------------------------------
        // REMOVE PRODUCT FROM LOCAL LIST
        // ------------------------------------------------------

        products.removeWhere(
              (product) =>
          product.id.toString() == productId,
        );

        // ------------------------------------------------------
        // UPDATE TOTAL
        // ------------------------------------------------------

        if (totalData > 0) {
          totalData--;
        }

        // ------------------------------------------------------
        // CLEAR ERROR
        // ------------------------------------------------------

        errorMessage = '';

        debugPrint(
          'Product deleted successfully.',
        );

        return true;
      }

      // ========================================================
      // API ERROR
      // ========================================================

      errorMessage =
          response['msg']?.toString() ??
              'Unable to delete product.';

      return false;
    } catch (e, stackTrace) {
      // ========================================================
      // EXCEPTION
      // ========================================================

      errorMessage = 'Something went wrong: $e';

      debugPrint(
        'Delete Product Error: $e',
      );

      debugPrint(
        'Delete Product StackTrace: $stackTrace',
      );

      return false;
    } finally {
      // ========================================================
      // RESET DELETE LOADING
      // ========================================================

      isDeleting = false;

      notifyListeners();
    }
  }

  // ============================================================
  // RESET PAGINATION
  // ============================================================

  void _resetPagination() {
    offset = 0;

    totalData = 0;

    products.clear();

    errorMessage = '';
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    if (isLoading) {
      return;
    }

    await fetchProducts(
      refresh: true,
    );
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  void loadMore() {
    if (isLoading) {
      return;
    }

    if (isLoadingMore) {
      return;
    }

    if (!hasMore) {
      return;
    }

    fetchProducts();
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void clearSearch() {
    if (searchController.text.isEmpty) {
      return;
    }

    searchController.clear();
  }

  // ============================================================
  // REQUEST DEBUG
  // ============================================================

  void _printRequest(
      Map<String, String> requestBody,
      ) {
    debugPrint(
      '================================================',
    );

    debugPrint(
      'Product List Request',
    );

    debugPrint(
      'URL: ${ApiPath.getProductList}',
    );

    debugPrint(
      'BODY: $requestBody',
    );

    debugPrint(
      '================================================',
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchDebounce?.cancel();

    searchController.removeListener(
      _onSearchChanged,
    );

    searchController.dispose();

    super.dispose();
  }
}