import 'package:flutter/material.dart';

import '../../../core/network/api_path.dart';
import '../../../core/network/api_repository.dart';
import '../model/logs_model.dart';

class LogController extends ChangeNotifier {
  LogController({required this.invId,required this.invType,});

  final String invId;
  final String invType;

  bool isLoading = false;
  String errorMessage = '';
  List<LogModel> logs = [];

  Future<void> fetchLogs() async {
    if (invId.trim().isEmpty) {
      errorMessage = 'Invoice ID is required';
      logs = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiProvider.createServerRequest(
        apiUrl: ApiPath.logDetailList,
        requestBody: {'inv_id': invId, 'inv_type': invType},
        isFormData: true,

      );


      final parsed = LogResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      if (parsed.error) {
        logs = parsed.logs;
        errorMessage = '';
      } else {
        logs = [];
        errorMessage = parsed.msg.isNotEmpty
            ? parsed.msg
            : 'Unable to load logs';
      }
    } catch (e) {
      logs = [];
      errorMessage = 'Unable to load logs. Please try again.';
      debugPrint('LogController.fetchLogs error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
