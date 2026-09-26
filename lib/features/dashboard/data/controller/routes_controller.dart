import 'package:flutter/material.dart';

class RoutesController extends ChangeNotifier {

  bool isLoading = false;

  String selectedRoutes = '/dashboard';

  static const String dashboard = '/dashboard';
  static const String purchasePage = '/purchasePage';
  static const String expense = '/expense';
  static const String report = '/report';
  static const String taskDetail = '/taskDetail';
  static const String profile = '/profile';
  static const String vendor = '/vendor';
  static const String otherChargeScreen = '/otherChargeScreen';

  void enableLoader(){
    isLoading = true;
    notifyListeners();
  }

  void disableLoader(){
    isLoading = false;
    notifyListeners();
  }

  Future<void> setRoute(String route)async{
    enableLoader();
    await Future.delayed(Duration(milliseconds: 600));
    disableLoader();
    selectedRoutes = route;
  }

  void update(){
    notifyListeners();
  }

}