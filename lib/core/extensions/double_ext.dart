
import 'package:flutter/cupertino.dart';
import 'context_ext.dart';

extension DoubleExt on double {
  Widget get heightBox => SizedBox(
        height: toDouble(),
      );

  Widget get widthBox => SizedBox(
        width: toDouble(),
      );

  percentHeight(BuildContext context, {bool boxRequired = true}) {
    double finalHeight = context.getSize.height * toDouble() / 100;
    if (!boxRequired) {
      return finalHeight;
    }

    return SizedBox(height: finalHeight);
  }

  percentWidth(BuildContext context, {bool boxRequired = true}) {
    double finalWidth = context.getSize.width * toDouble() / 100;
    if (!boxRequired) {
      return finalWidth;
    }

    return SizedBox(width: finalWidth);
  }

  double textbyPercent(
    BuildContext context,
  ) {
    return MediaQuery.of(context).textScaler.scale(1) * this;
  }


}
