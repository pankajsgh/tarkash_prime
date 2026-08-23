
import 'dart:convert';

import 'package:dio/dio.dart';

class ApiProvider {

  static void printLog(dynamic message) {
    assert(() {
      print(message);
      return true;
    }());
  }

  static Dio dio = Dio()..options.connectTimeout = const Duration(seconds: 10);

  static Future<Map<String, dynamic>> createServerRequest({required String apiUrl, Map<String, dynamic>? requestBody, isFormData = false}) async{
    Map<String, dynamic> responseData = {};
    Response response;

    printLog('apiDebugReq, $apiUrl, $requestBody, $isFormData');

    if(requestBody!=null){
      try{
        response = await dio.post(
            options: Options(
              headers: {
                'Content-Type': isFormData ? 'multipart/form-data' : 'application/json',
              },
            ),
            apiUrl,
            data: isFormData?FormData.fromMap(requestBody):jsonEncode(requestBody));
      } catch(e){
        print(e);
        response = Response(requestOptions: RequestOptions());
      }

    }
    else{
      try{
        response = await dio.get(apiUrl);
      } catch(e){
        response = Response(requestOptions: RequestOptions());
      }
    }
    if(response.statusCode==200){
      try{
        responseData = response.data;
      }catch(error){
        responseData = {};
      }
    }
    else if(response.statusCode==400){
      printLog('requestCheck04, $response');
      responseData = {};
    }

    return responseData;
  }

}