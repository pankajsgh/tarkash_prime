import 'package:flutter/material.dart';

import '../../../../core/network/api_path.dart';
import '../../../../core/network/api_repository.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/sms_user_consent_service.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/ulitls/utility.dart';
import '../../../../core/vars/global_vars.dart';
import '../../../../core/widget/toast.dart';


class AuthController extends ChangeNotifier {

  String displayNo ="";
  String _otp= "";
  String tempId = "";
  List<String>  otp = [];
  TextEditingController mobileController = TextEditingController();

  TextEditingController otpController = TextEditingController();
  bool showOtp = false;
  bool isLoading = false;
  bool _isListening = false;
  String? otpCode;


  void setOtp(String otp){
    _otp = otp;
  }

  void enableLoader(){
    isLoading = true;
    notifyListeners();
  }


  Future<void> startOtpListener(BuildContext context) async {

    if (_isListening) {
      return;
    }

    _isListening = true;

    try {

      final message = await SmsUserConsentService.startListening();

      if (message == null) {
        return;
      }

      print('SMS: $message');

      // Extract 6 digit OTP
      final match = RegExp(
        r'\b\d{4}\b',
      ).firstMatch(message);

      if (match != null) {

        otpCode = match.group(0);

        await Future.delayed(Duration(milliseconds: 1200), (){});
        if(otpCode!=null && otpCode!.length==4)
        {
          otp = [];
          for(var x in otpCode!.split(""))
          {
            otp.add(x);
          }
          print("this is good7854");

          if(otp.length==4)
          {
            enableLoader();
            await Future.delayed(Duration(milliseconds: 1600));
            setOtp(otpCode!);
            verifyOtp(context);
          }
        }
        // Automatically verify
      }

    } catch (e){
      print(e);
    }
    finally {
      _isListening = false;
    }
  }


  Future sendOtp(BuildContext context) async {


    if(mobileController.text.length!=10)
    {
      Toast.show(message: "Enter valid Mobile no");
      return true;
    }

    enableLoader();

    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    String deviceId = await getDeviceId();
    Map<String, dynamic> requestBody = {};
    requestBody['mobile'] = mobileController.text;
    requestBody['device_id'] = deviceId;

    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.loginUrl, requestBody: requestBody, isFormData: true);
    printLog('responseCheck, $response');

    try{
      if (response['error']!=null && response['error']) {
        tempId = response['uid']?? "";
        displayNo = response['mobile']?? "";
        showOtp = true;
        showMessage("this is otp:${response['otp']}", ToastType.info);
        startOtpListener(context);
      }
      else {
        showMessage(response['msg']?? "Server error", ToastType.error);
      }
    } catch (e){
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }


  Future verifyOtp(context) async {

    if(_otp.length!=4)
    {
      Toast.show(message: "Enter valid OTP");
      return true;
    }

    enableLoader();

    await Future.delayed(
      const Duration(milliseconds: 600),
    );

    String deviceId = await getDeviceId();
    Map<String, dynamic> requestBody = {};
    requestBody['uid'] = tempId;
    requestBody['otp'] = _otp;
    requestBody['device_id'] = deviceId;
    var response = await ApiProvider.createServerRequest(apiUrl: ApiPath.verifyUrl, requestBody: requestBody, isFormData: true);

    printLog('responseCheck, $response');

    try{
      if (response['error']!=null && response['error']) {
        tempId = response['id']?? "";
        displayNo = response['mobile']?? "";
        var name = response['name']?? "";
        var role = response['role']?? "";
        GlobalVars.userName = name;
        GlobalVars.userId = tempId;
        GlobalVars.roleId = role;
        SessionManager.setLoginId(userId: tempId, roleId: role, accessKey: "", name: name);

        Navigator.pushReplacementNamed(context, Routes.dashboard);
      }
      else {
        showMessage(response['msg'], ToastType.error);
      }
    } catch (e){
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }

  void changeNo(){
    showOtp = false;
    notifyListeners();
  }
}