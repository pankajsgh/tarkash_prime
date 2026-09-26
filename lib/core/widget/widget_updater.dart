import 'package:flutter/cupertino.dart';


class WidgetUpdater extends ChangeNotifier {
  bool isLoading = false;

  void enableLoader(){
    isLoading = true;
    notifyListeners();
  }

  void disableLoader(){
    isLoading = false;
    notifyListeners();
  }

  void update (){
    notifyListeners();
  }

}