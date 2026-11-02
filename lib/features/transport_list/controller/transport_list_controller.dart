
import 'dart:async';

import 'package:calculation_panel/core/network/api_path.dart';
import 'package:calculation_panel/core/network/api_repository.dart';
import 'package:flutter/material.dart';
import '../../../core/widget/transport_field.dart';
import '../../purchase_challan/model/transport_model.dart';


class TransportListController extends ChangeNotifier {
  TransportListController() {
    loadTransports();
  }

  final TextEditingController searchController = TextEditingController();

  List<TransportModel> transports = [];

  bool isLoading = false;
  String errorMessage = '';
  String totalData = '0';

  Timer? _debounce;
  int _requestId = 0;

  Future<void> loadTransports({String? search}) async {
    final requestId = ++_requestId;

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.getTransportList,
        requestBody: {
          'search': search ?? searchController.text.trim(),
          'limit': '0',
        },
        isFormData: true,
      );

      if (requestId != _requestId) return;



      if(response["error"]==true) {
        final result = TransportResponse.fromJson(
        Map<String, dynamic>.from(response),
      );

        transports = result.transportList;
        totalData = result.totalData.isNotEmpty
            ? result.totalData
            : result.nums;
      }


    } catch (e) {
      if (requestId != _requestId) return;

      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
          () => loadTransports(search: value.trim()),
    );
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    loadTransports(search: '');
  }

  Future<void> refresh() async {
    await loadTransports();
  }

  @override
  void dispose() {
    _requestId++;
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
