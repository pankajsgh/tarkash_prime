import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../../core/vars/global_vars.dart';

class SplashController extends ChangeNotifier {

  bool isLoading = true;
  bool isLogin = false;


  Future<void> checkLogin() async {

    GlobalVars.userId = await SessionManager.getLoginId();
    GlobalVars.userName = await SessionManager.getName();
    GlobalVars.roleId = await SessionManager.getRoleId();

    await Future.delayed(
      const Duration(
        milliseconds: 600,
      ),
    );

    GlobalVars.userId = "353";
    if(GlobalVars.userId.isNotEmpty)
    {
      isLogin = true;
    }

    isLoading = false;
    notifyListeners();
  }
}