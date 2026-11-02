
import 'dart:convert';
import 'dart:math';

import 'package:calculation_panel/core/database/local_data/agent_json.dart';
import 'package:calculation_panel/core/database/local_data/party_json.dart';
import 'package:calculation_panel/core/database/local_data/product_json.dart';
import 'package:calculation_panel/core/database/local_data/store_json.dart';
import 'package:calculation_panel/core/database/local_data/transport_json.dart';
import 'package:dio/dio.dart';
import 'package:pdf/widgets.dart';

import '../database/local_data/challan_json.dart';
import '../database/local_data/dashboardJson.dart';
import '../database/local_data/team_list.dart';
import '../vars/global_vars.dart';

class LocalProvider {

  Map<String, dynamic> responseData = {};

  static String generateOTP() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  static Future<Map<String, dynamic>> createLocalRequest({required String apiUrl, Map<String, dynamic>? requestBody, isFormData = false}) async {
    Map<String, dynamic> responseData = {
      'error': true,
      'status':true,
    };

    print("this is local data");
    print(apiUrl);
    if(apiUrl.split('/').last == 'Dashboard.php')
    {
      return dashboardJson;
    }
    if(apiUrl.split('/').last == 'purchase_challan_list.php')
    {
      responseData['data'] = purchaseChallanJson;
      return responseData;
    }

    if(apiUrl.split('/').last == 'PartyList.php')
    {
      return partyJson;
    }
    if(apiUrl.split('/').last == 'TransportList.php')
    {
      return transportJson;
    }
    if(apiUrl.split('/').last == 'StoreList.php')
    {
      return storeJson;
    }
    if(apiUrl.split('/').last == 'agentlist.php')
    {
      return agentJson;
    }
    if(apiUrl.split('/').last == 'color_list.php')
    {
      return transportJson;
    }
    if(apiUrl.split('/').last == 'size_list.php')
    {
      return transportJson;
    }
    if(apiUrl.split('/').last == 'hsn_list.php')
    {
      return transportJson;
    }
    if(apiUrl.split('/').last == 'product_list.php')
    {
      return productJson;
    }
    if(apiUrl.split('/').last == 'login.php')
    {

      if(requestBody!=null)
      {
        var mobile = requestBody["mobile"];
        print("Checking you mobile");
        print(mobile);

        String otp = generateOTP();
        print("Your OTP: $otp");

        for(var x in teamJson['data'])
        {

          if(x["mobile"]== mobile)
            {

              return
                {
                  "code": 1,
                  "error": true,
                  "uid": x['id'],
                  "mobile": x['9119766665'],
                  "otp": otp,
                  "msg": "OTP sent successfully"
              };
            }
        }
      }

      return {
        "code": 1,
        "error": false,
        "uid": '',
        "mobile": '',
        "otp": '',
        "msg": "User not found"
      };
    }
    if (apiUrl.split('/').last == 'verify.php') {

      if (requestBody != null) {

        var uid = requestBody["uid"];
        var otp = requestBody["otp"];

        print("Verifying OTP: $otp");

        for (var x in teamJson['data']) {

          if (x["id"] == uid) {

            if (otp == '1234') {

              return {
                "code": "1",
                "error": true,
                "id": x["id"],
                "mobile": x["mobile"],
                "name": x["employee_name"],
                "role": x["field_14"],
                "msg": "Login successfully"
              };

            } else {

              return {
                "code": "0",
                "error": false,
                "id": "",
                "mobile": "",
                "name": "",
                "role": "",
                "msg": "Invalid OTP"
              };
            }
          }
        }
      }

      return {
        "code": "0",
        "error": false,
        "id": "",
        "mobile": "",
        "name": "",
        "role": "",
        "msg": "User not found"
      };
    }

    return responseData;
  }


}