
import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  Size get getSize => MediaQuery.of(this).size;

  void unFocus() {
    FocusScope.of(this).unfocus();
  }

  void to(WidgetBuilder builder, {Function? backAction}) {
    Navigator.push(this, MaterialPageRoute(builder: builder)).then((value){
        if(backAction!=null){ backAction(); }
    });
  }

  void off(WidgetBuilder builder) {
    Navigator.pushReplacement(this, MaterialPageRoute(builder: builder));
  }

  void offAll(WidgetBuilder builder) {
    Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(builder: builder),
      (route) => false,
    );
  }

  void pop() {
    Navigator.pop(this);
  }


}
