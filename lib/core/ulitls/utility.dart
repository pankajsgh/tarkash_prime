import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../constants/app_constants.dart';
import '../widget/toast.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

Future<bool> hasInternet() async {
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 2);

    final request = await client.getUrl(
      Uri.parse('https://www.google.com'),
    );

    final response = await request.close();

    client.close();

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

IconData getCatIcon(String cat) {
 try{
   final catWords = _words(cat);

   IconData bestIcon = Icons.code_rounded;
   int bestScore = 0;

   for (final item in categories) {
     final score = _words(item["title"])
         .intersection(catWords)
         .length;

     if (score > bestScore) {
       bestScore = score;
       bestIcon = item["icon"] as IconData;
     }
   }

   return bestIcon;
 } catch(e){
   print(e);
 }
 return Icons.code_rounded;
}

Set<String> _words(String text) => text.toLowerCase().trim().split(RegExp(r'\s+')).toSet();

void showMessage(String message, ToastType info, { String? title}){
  Toast.show(
      type: info,
      title: title,
      duration: Duration(milliseconds: 2000),
      message: message
  );
}


String getCurrentDate() {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
}

Future<String> getDate({required BuildContext context, DateTime? lastDate, DateTime? firstDate, DateTime? selectedDate}) async{
  var value = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2050),
      confirmText: 'SELECT',
      cancelText: 'CANCEL'
  );

  if(value!=null){
    String month = value.month.toString();
    if (value.month
        .toString()
        .length == 1) {
      month = '0${value.month.toString()}';
    }

    String day = value.day.toString();
    if (value.day
        .toString()
        .length == 1) {
      day = '0${value.day.toString()}';
    }

    return '$day/$month/${value.year}';
  }
  return '';
}

printLog(String msg){
  debugPrint(msg);
}

Future<void> navigateScreen({
  required BuildContext context,
  required String path,
  Map<String, dynamic>? params,
  bool isReplace=false,
  bool isClearAll=false,
  Function? backAction
}) async
{
  if(isReplace){
    Navigator.pushReplacementNamed(context, path, arguments: params).then((value) {
      if(backAction!=null){
        backAction(value);
      }
    } );
  }
  else if(isClearAll){
    Navigator.pushNamedAndRemoveUntil(
      context,
      path,
          (Route<dynamic> route) => false,
    );
  }
  else{
    Navigator.pushNamed(context, path, arguments: params).then((value) {
      if(backAction!=null){
      backAction(value);
    }}
    );
  }
}


String getInitials(String name) {
  List<String> parts = name.trim().split(' ');

  if (parts.length == 1) {
    return parts[0][0]; // Get the first character
  }

  String firstNameInitial = parts[0][0]; // First character of the first name
  String lastNameInitial = parts[parts.length - 1][0]; // First character of the last name

  return '$firstNameInitial$lastNameInitial';
}


Future<String> getDeviceId() async {
  try {
    final deviceInfo = DeviceInfoPlugin();

    // =========================
    // WEB
    // =========================
    if (kIsWeb) {
      final result = await deviceInfo.webBrowserInfo;

      final deviceId =
          '${result.browserName}_'
          '${result.platform}_'
          '${result.userAgent}';

      printLog('Web deviceId: $deviceId');

      return deviceId;
    }

    // =========================
    // ANDROID
    // =========================
    if (Platform.isAndroid) {
      final result = await deviceInfo.androidInfo;

      final   deviceId = '${result.id}_${result.brand}_${result.type}_${result.product}_${result.model}_${result.product}_${result.display}_${result.host}';

      printLog('Android deviceId: $deviceId');

      return deviceId;
    }

    // =========================
    // IOS
    // =========================
    if (Platform.isIOS) {
      final result = await deviceInfo.iosInfo;

      final deviceId =
          '${result.identifierForVendor}_'
          '${result.model}_'
          '${result.systemVersion}';

      printLog('iOS deviceId: $deviceId');

      return deviceId;
    }

    // =========================
    // WINDOWS
    // =========================
    if (Platform.isWindows) {
      final result = await deviceInfo.windowsInfo;

      final deviceId =
          '${result.computerName}_'
          '${result.productName}_'
          '${result.displayVersion}_'
          '${result.buildNumber}_'
          '${result.registeredOwner}';

      printLog('Windows deviceId: $deviceId');

      return deviceId;
    }

    // =========================
    // MACOS
    // =========================
    if (Platform.isMacOS) {
      final result = await deviceInfo.macOsInfo;

      final deviceId =
          '${result.computerName}_'
          '${result.model}_'
          '${result.osRelease}';

      printLog('macOS deviceId: $deviceId');

      return deviceId;
    }

    // =========================
    // LINUX
    // =========================
    if (Platform.isLinux) {
      final result = await deviceInfo.linuxInfo;

      final deviceId =
          '${result.machineId}_'
          '${result.name}_'
          '${result.versionId}';

      printLog('Linux deviceId: $deviceId');

      return deviceId;
    }

    return '';
  } catch (e) {
    printLog('Failed to get device ID: $e');
    return '';
  }
}



void makeDebugGetRequest({required String url, required Map<String, dynamic> requestBody}) {
  final uri = Uri.parse(url);

  // Custom encode function that preserves slashes
  String encodeKeepSlash(String value) {
    return Uri.encodeComponent(value).replaceAll('%2F', '/');
  }

  // Build query string manually
  final query = requestBody.entries.map((e) {
    final key = encodeKeepSlash(e.key);
    final value = e.value.toString();

    if (value.isEmpty) {
      return key; // only key, no "="
    } else {
      return "$key=${encodeKeepSlash(value)}";
    }
  }).join("&");

  final finalUrl = "${uri.origin}${uri.path}?$query";
  printLog(finalUrl);
}


Color getStatusColor(String status) {
  switch (status) {
    case "Pending":
      return Colors.orange;
    case "In Progress":
      return Colors.blue;
    case "Completed":
      return Colors.green;
    case "Cancelled":
      return Colors.red;
    default:
      return Colors.grey;
  }
}

IconData statusIcon(String status) {
  switch (status) {
    case "Pending":
      return Icons.schedule_rounded;
    case "In Progress":
      return Icons.autorenew_rounded;
    case "Completed":
      return Icons.check_circle_rounded;
    case "Cancelled":
      return Icons.cancel_rounded;
    default:
      return Icons.circle;
  }
}

String formatDate(DateTime? date) {

  if (date == null) {
    return "Select date";
  }

  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year}";
}




double getPercentage(int value, int total) {
  if (total == 0) return 0.0;

  return double.parse(
    ((value / total) * 100).toStringAsFixed(1),
  );
}