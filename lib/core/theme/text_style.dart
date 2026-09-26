
import 'package:flutter/material.dart';
import 'colors.dart';

Color statusColor(String status) {
  switch (status) {
    case "In Progress":
      return primaryAppColor;
    case "Pending":
      return Colors.orange;
    case "Completed":
      return Colors.green;
    default:
      return Colors.grey;
  }
}