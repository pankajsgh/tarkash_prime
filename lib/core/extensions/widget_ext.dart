
import 'package:flutter/material.dart';

extension WidgetExt on Widget {
  Widget onTap(
      VoidCallback? onTap, {
        BorderRadius? borderRadius,
        Color? splashColor,
        Color? highlightColor,
        Color? hoverColor,
        Color? focusColor,
        Color? overlayColor,
        bool enableFeedback = true,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: splashColor,
        highlightColor: highlightColor,
        hoverColor: hoverColor,
        focusColor: focusColor,
        overlayColor: overlayColor == null
            ? null
            : WidgetStateProperty.all(overlayColor),
        enableFeedback: enableFeedback,
        child: this,
      ),
    );
  }

  Widget padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    EdgeInsets edgeInsets;

    if (all != null) {
      edgeInsets = EdgeInsets.all(all);
    } else if (horizontal != null || vertical != null) {
      edgeInsets = EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    } else {
      edgeInsets = EdgeInsets.only(
        left: left ?? 0,
        top: top ?? 0,
        right: right ?? 0,
        bottom: bottom ?? 0,
      );
    }

    return Padding(
      padding: edgeInsets,
      child: this,
    );
  }


  Widget margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    EdgeInsets edgeInsets;

    if (all != null) {
      edgeInsets = EdgeInsets.all(all);
    } else if (horizontal != null || vertical != null) {
      edgeInsets = EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    } else {
      edgeInsets = EdgeInsets.only(
        left: left ?? 0,
        top: top ?? 0,
        right: right ?? 0,
        bottom: bottom ?? 0,
      );
    }

    return Container(
      margin: edgeInsets,
      child: this,
    );
  }
}