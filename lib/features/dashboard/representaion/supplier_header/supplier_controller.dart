import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/features/dashboard/model/store_model.dart';
import 'package:calculation_panel/features/dashboard/model/transport_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/api_path.dart';
import '../../../../core/network/api_repository.dart';
import '../../../../core/ulitls/utility.dart';
import 'model/supplier_model.dart';

class SupplierController extends ChangeNotifier {

  final TextEditingController challanController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Party? selectedSupplier;
  StoreModel? selectedStore;
  TransportModel? selectedTransport;
  String? selectedAgent;
  String? selectedAdditionalCharge;

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

  void setSupplier(Party? supplier) {
    selectedSupplier = supplier;
    if(selectedSupplier!=null && selectedSupplier!.transport.name.isNotEmpty)
   {
      selectedTransport = TransportModel(id: selectedSupplier!.transport.id, transport:  selectedSupplier!.transport.name,  owner: '', mobile: '', location: '', address: '');
   }

    if (supplier == null) {
      gstinController.clear();

      selectedStore = null;
      selectedTransport = null;
      selectedAgent = null;
    } else {
      gstinController.text = supplier.gstNo;

      if(selectedSupplier!.transport.name.isNotEmpty)
        {
          selectedTransport = TransportModel(id: selectedSupplier!.transport.id, transport:  selectedSupplier!.transport.name,  owner: '', mobile: '', location: '', address: '');
        } else {
        selectedTransport = null;
      }

      selectedAgent = supplier.agency.name;
    }

    notifyListeners();
  }


  void setStore(StoreModel? value) {
    if (selectedStore == value) return;

    selectedStore = value;

    notifyListeners();
  }


  void setTransport(TransportModel? value) {
    if (selectedTransport == value) return;

    selectedTransport = value;

    notifyListeners();
  }


  void setAgent(String? value) {
    if (selectedAgent == value) return;

    selectedAgent = value;

    notifyListeners();
  }

  void formChanged() {
    notifyListeners();
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');

    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);

    final month = int.tryParse(parts[1]);

    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final currentDate = _parseDate(dateController.text);

    final result = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result == null) return;

    dateController.text = formatDate(result);
    GlobalVars.currentData = dateController.text;
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


