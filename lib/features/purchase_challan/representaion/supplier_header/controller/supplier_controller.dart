import 'package:calculation_panel/core/database/local_data/transport_json.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:flutter/material.dart';
import '../../../../../core/network/api_path.dart';
import '../../../../../core/network/api_repository.dart';
import '../../../model/store_model.dart';
import '../../../model/transport_model.dart';
import '../model/supplier_model.dart';

class SupplierController extends ChangeNotifier {

  final TextEditingController challanController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<Party> suppliers = [];
  List<StoreModel> stores = [];
  List<TransportModel> transports =  [];

  Future<void> getPartyTypeList(String search) async {

    Map<String, dynamic> requestBody = {};
    requestBody['PartyType'] = "2";
    requestBody['search'] = search;
    requestBody['limit'] = "0";
    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.getPartyList, requestBody: requestBody, isFormData: true);

    if(response['error']!=null && response['error'])
    {
      try{
        var data = PartyModel.fromJson(response);
        suppliers = data.partyList;
        notifyListeners();
      } catch(e){
        print(e);
      }
    } else {
      suppliers.clear();
    }

    getTransportList('');
    stores = GlobalVars.storeList;
    notifyListeners();
  }
  Future<void> getTransportList(String search) async {

    Map<String, dynamic> requestBody = {};
    requestBody['search'] = search;
    requestBody['limit'] = "0";

    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.getTransportList, requestBody: requestBody, isFormData: true);


    if(GlobalVars.isOffline)
      {
        response = transportJson;
      }


    if(response['error']!=null && response['error'])
    {
      try{
        var data = TransportResponse.fromJson(response);
        transports = data.transportList;
        notifyListeners();
      } catch(e){
        print(e);
      }
    }
    stores = GlobalVars.storeList;

    notifyListeners();
  }

  void formChanged() {
    notifyListeners();
  }

  void setDate(String date)
  {
    dateController.text = date;
    notifyListeners();
  }

  @override
  void dispose() {

    challanController.dispose();
    gstinController.dispose();
    dateController.dispose();
    super.dispose();
  }
}


