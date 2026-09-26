import 'package:calculation_panel/core/network/api_path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/purchase_challan_list_model.dart';

class PurchaseChallanListController extends ChangeNotifier {
  final Dio dio;

  PurchaseChallanListController({
    required this.dio,
  });

  bool isLoading = false;
  String? errorMessage;

  List<PurchaseChallanListModel> challans = [];

  Future<void> getAllChallans() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {

      print(ApiPath.purchaseChallansListApi);
      final response = await dio.get(
        ApiPath.purchaseChallansListApi
      );

      final responseData = response.data;

      if (responseData is Map &&
          responseData['status'] == true) {
        final data = responseData['data'];

        if (data is List) {
          challans = data
              .whereType<Map>()
              .map(
                (item) =>
                PurchaseChallanListModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
          )
              .toList();
        } else {
          challans = [];
        }
      } else {
        challans = [];

        errorMessage =
        responseData is Map
            ? responseData['message']
            ?.toString()
            : 'Unable to load challans';
      }
    } on DioException catch (e) {
      errorMessage =
      e.response?.data is Map
          ? e.response?.data['message']
          ?.toString()
          : e.message ?? 'Network error';
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}