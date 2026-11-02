
import 'dart:async';

import 'package:calculation_panel/core/widget/app_loader.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/api_path.dart';
import '../../../../core/network/api_repository.dart';
import '../models/model_voucher_configuration.dart';

class SeriesListController extends ChangeNotifier {

  List<VoucherType> products = [];

  bool isLoading = false;

  bool isLoadingMore = false;

  bool isDeleting = false;

  String errorMessage = '';

  int get showingCount {
    return products.length;
  }

  Future<void> fetchDataList({
    bool refresh = false,
  }) async {

    if (isLoading || isLoadingMore) {
      return;
    }

    if (refresh) {


      isLoading = true;

      notifyListeners();
    }
    else {


      isLoadingMore = true;

      notifyListeners();
    }

    try {

      final response =
      await ApiProvider.createServerRequest(
        apiUrl: ApiPath.urlVoucherConfigurationList,
        isFormData: true,
      );

      debugPrint(
        'Voucher List Response: $response',
      );

      final data = ModelVoucherConfigurationList.fromJson(
        Map<String, dynamic>.from(
          response,
        ),
      );

      if (data.code == 1 && data.error == true) {
        _handleSuccess(
          data: data,
          refresh: refresh,
        );

        return;
      }

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

  void _handleSuccess({
    required ModelVoucherConfigurationList data,
    required bool refresh,
  }) {


    final List<VoucherType> newProducts =
    List<VoucherType>.from(
      data.data,
    );

    if (refresh) {
      products = newProducts;
    }

    else {
      products.addAll(
        newProducts,
      );
    }

    errorMessage = '';

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
      '================================================',
    );
  }

  Future<void> refresh() async {
    if (isLoading) {
      return;
    }

    await fetchDataList(
      refresh: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> requestDeleteSeries({required BuildContext context, required String id}) async {

    AppLoader.showLoader(context);
    final response = await ApiProvider.createServerRequest(
      apiUrl: ApiPath.urlVoucherConfigurationDelete,
      requestBody: {'id': id},
      isFormData: true,
    );
    AppLoader.hideLoader(context);

    if(response['error']){
      fetchDataList(refresh: true);
    }
    else{
      Navigator.pop(context);
    }
  }

}