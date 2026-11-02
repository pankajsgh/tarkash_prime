import 'package:calculation_panel/core/database/local_data/agent_json.dart';
import 'package:calculation_panel/core/database/local_data/store_json.dart';
import 'package:calculation_panel/core/database/local_data/transport_json.dart';
import 'package:calculation_panel/core/network/api_path.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/database/sql_databaes/purchase_challan_database.dart';
import '../../../core/network/api_repository.dart';
import '../model/purchase_challan_list_model.dart';

class PurchaseChallanListController extends ChangeNotifier {
  final String listApi;

  PurchaseChallanListController({
    required this.listApi,
  });

  bool isLoading = false;
  String? errorMessage;

  List<PurchaseChallanListModel> challans = [];

  Future<void> getAllChallans() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {

        print(listApi);

        final response = await ApiProvider.createServerRequest(
          apiUrl:  listApi
        );


        if (response['status'] == true) {
          final data = response['data'];

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

          errorMessage = response is Map
              ? response['message']?.toString()
              : 'Unable to load challans';
        }

    } on DioException catch (e) {
      errorMessage = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : e.message ?? 'Network error';
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteChallan(String id, {required String apiPath}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {


      // ======================================================
      // ONLINE
      // ======================================================

      final request = {
        'id': id.toString(),
      };


      final response =
      await ApiProvider.createServerRequest(
        apiUrl: apiPath,
        requestBody: request,
        isFormData: true,
      );

      if (response['status'] == true) {
        return true;
      }

      errorMessage =
          response['message']?.toString() ??
              'Failed to delete purchase challan';

      return false;
    } on DioException catch (e) {
      errorMessage = e.response?.data is Map
          ? e.response?.data['message']?.toString() ??
          'Failed to delete purchase challan'
          : e.message ?? 'Network error';

      return false;
    } catch (e) {
      errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelChallan(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {


      // ======================================================
      // ONLINE
      // ======================================================

      final request = {
        'id': id.toString(),
        'status': 'Cancel',
      };

      final response =
      await ApiProvider.createServerRequest(
        apiUrl: ApiPath.cancelPurchaseChallanApi,
        requestBody: request,
        isFormData: true,
      );

      if (response['status'] == true) {
        return true;
      }

      errorMessage =
          response['message']?.toString() ??
              'Failed to delete purchase challan';

      return false;
    } on DioException catch (e) {
      errorMessage = e.response?.data is Map
          ? e.response?.data['message']?.toString() ??
          'Failed to delete purchase challan'
          : e.message ?? 'Network error';

      return false;
    } catch (e) {
      errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


}