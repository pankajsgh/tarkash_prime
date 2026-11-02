import 'package:flutter/material.dart';

import '../../../../core/routes/routes.dart';


class RoutesController extends ChangeNotifier {

  bool isLoading = false;

  String selectedRoutes = Routes.dashboard;
  Map<String, dynamic> params = {};
  void enableLoader(){
    isLoading = true;
    notifyListeners();
  }

  void disableLoader(){
    isLoading = false;
    notifyListeners();
  }

  Future<void> setRoute(String route, {Map<String, dynamic>? data})async{
    enableLoader();
    await Future.delayed(Duration(milliseconds: 600));
    disableLoader();
    if(data!=null)
      {
        params = data;
      }
    selectedRoutes = route;
  }

  void update(){
    notifyListeners();
  }

}