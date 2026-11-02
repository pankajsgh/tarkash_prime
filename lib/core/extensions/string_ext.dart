
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart' as mp;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExt on String{
  Future<String> get gtBase64ByPath async {
    final file = File(this);
    if (await file.exists()) {
      return base64Encode(file.readAsBytesSync());
    } else {
      return "";
    }
  }
  String withParams() {
    // Split URL and params
    final parts = split(',');
    final baseUrl = parts[0].trim();
    final rawParams = parts.sublist(1).join(',').trim(); // handle extra commas safely

    // Remove { } and split key-value pairs
    final params = rawParams
        .replaceAll('{', '')
        .replaceAll('}', '')
        .split(',')
        .map((e) => e.split(':').map((s) => s.trim()).toList())
        .map((pair) => MapEntry(
        pair[0],                      // always take the key
        pair.length > 1 ? pair[1] : "" // if value missing → empty string
    ))
        .toList();

    // Build Uri
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: Map.fromEntries(params),
    );

    return uri.toString();
  }

  withoutDecimal(){
    return double.parse(this).toStringAsFixed(0);
  }

  String toDayMonth() {
    try {
      final parts = split("/");
      if (parts.length < 2) return this;

      final day = parts[0];
      final month = parts[1];

      const months = {
        "01": "JAN",
        "02": "FEB",
        "03": "MAR",
        "04": "APR",
        "05": "MAY",
        "06": "JUN",
        "07": "JUL",
        "08": "AUG",
        "09": "SEP",
        "10": "OCT",
        "11": "NOV",
        "12": "DEC",
      };

      return "$day ${months[month] ?? ''}";
    } catch (_) {
      return this;
    }
  }

  Future<dynamic> toMultipartAudio() async {

    if (isEmpty || this == 'Record Voice') {
      return '';
    }

    return await mp.MultipartFile.fromFile(
      this,
      filename: split('/').last,
    );
  }

  String amountInNumberFormat() {
    if (isEmpty) return "0";

    String value = replaceAll(',', '');

    bool isNegative = value.startsWith('-');
    if (isNegative) value = value.substring(1);

    // Split integer & decimal
    List<String> split = value.split('.');
    String intPart = split[0];
    String? decimalPart = split.length > 1 ? split[1] : null;

    // 🔥 Remove .00 case
    if (decimalPart != null && RegExp(r'^0+$').hasMatch(decimalPart)) {
      decimalPart = null;
    }

    if (intPart.length <= 3) {
      return (isNegative ? "-" : "") +
          intPart +
          (decimalPart != null ? ".$decimalPart" : "");
    }

    String last3 = intPart.substring(intPart.length - 3);
    String rest = intPart.substring(0, intPart.length - 3);

    List<String> parts = [];

    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }

    if (rest.isNotEmpty) {
      parts.insert(0, rest);
    }

    String result = "${parts.join(',')},$last3";

    return (isNegative ? "-" : "") +
        result +
        (decimalPart != null ? ".$decimalPart" : "");
  }

  Text toText({double? fontSize, Color? color, FontWeight? fontWeight, String fontFamily = 'Roboto'}){
    return Text(this, style: TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    ),);
  }

  String formatDate() {
    if (trim().isEmpty) return '';

    final value = trim();

    final formats = [
      'dd/MM/yyyy HH:mm:ss',
      'dd/MM/yyyy',
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd',
    ];

    DateTime? parsedDate;

    for (final format in formats) {
      try {
        parsedDate = DateFormat(format).parseStrict(value);
        break;
      } catch (_) {
        // Try next format
      }
    }

    if (parsedDate == null) {
      return value;
    }

    final hasTime = value.contains(' ');

    if (hasTime) {
      return DateFormat('dd MMM yyyy hh:mm a').format(parsedDate);
    }

    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

}