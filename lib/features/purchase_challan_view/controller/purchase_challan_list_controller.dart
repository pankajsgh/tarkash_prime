import 'package:calculation_panel/core/database/local_data/agent_json.dart';
import 'package:calculation_panel/core/database/local_data/store_json.dart';
import 'package:calculation_panel/core/database/local_data/transport_json.dart';
import 'package:calculation_panel/core/network/api_path.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/database/sql_databaes/purchase_challan_database.dart';
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
      if (GlobalVars.isOffline) {
        // ======================================================
        // OFFLINE
        // ======================================================

        final data = await PurchaseDatabase.instance.getAllChallans();

        challans = data
            .map(
              (item) => PurchaseChallanListModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();

        for(var x in challans){
          if( x.storeId.isNotEmpty && x.storeName.isEmpty)
            {
             var stores =  storeJson['StoreList'] as List<Map<String, String>>;
             x.storeName = stores.firstWhere((e)=>e['id']==x.storeId)['ShortName']?? '';
            }

          if( x.transportId.isNotEmpty && x.transportName.isEmpty)
          {

            var transport =  transportJson['TransportList'] as List<Map<String, String>>;
            x.transportName = transport.firstWhere((e)=>e['id']==x.transportId)['transport']?? '';
          }
          if( x.agentId.isNotEmpty && x.agentName.isEmpty)
          {
            var agents =  agentJson['AgentList'] as List<Map<String, String>>;
            x.agentName = agents.firstWhere((e)=>e['id']==x.agentId)['Agent']?? '';
          }
        }

        print(
          'Offline challans loaded: ${challans.length}',
        );
      } else {
        // ======================================================
        // ONLINE
        // ======================================================

        print(ApiPath.purchaseChallansListApi);

        final response = await dio.get(
          ApiPath.purchaseChallansListApi,
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

          errorMessage = responseData is Map
              ? responseData['message']?.toString()
              : 'Unable to load challans';
        }
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
}