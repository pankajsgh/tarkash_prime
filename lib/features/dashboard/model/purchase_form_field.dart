import 'package:flutter/material.dart';

class PurchaseFormField {
  final String title;
  final Widget Function() builder;

  const PurchaseFormField({
    required this.title,
    required this.builder,
  });
}