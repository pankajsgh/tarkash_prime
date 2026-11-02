
import 'package:flutter/material.dart';

import '../extensions/string_ext.dart';

class DateField extends StatefulWidget {
  final ControllerDate controller;
  final String hintText;
  final double height;
  final double fontSize;
  final bool enabled;
  final VoidCallback? onSelected;
  final FocusNode focusNode;

  const DateField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText = 'Select date',
    this.height = 34,
    this.fontSize = 12,
    this.enabled = true,
    this.onSelected,
  });

  static const Color primaryBlue = Color(0xff3B82F6);
  static const Color textDark = Color(0xff1E293B);
  static const Color textLight = Color(0xff94A3B8);
  static const Color borderColor = Color(0xffE2E8F0);
  static const Color inputBg = Color(0xffF8FAFC);

  @override
  State<DateField> createState() => DateFieldState();
}

class DateFieldState extends State<DateField> {
  Future<void> openDatePicker() async {
    if (!widget.enabled) return;

    widget.focusNode.requestFocus();

    await widget.controller.selectDate(context);

    if (!mounted) return;

    widget.onSelected?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.hintText,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: DateField.textDark,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: widget.height,
          child: TextField(
            controller: widget.controller.dateController,
            focusNode: widget.focusNode,
            readOnly: true,
            enabled: widget.enabled,
            onTap: openDatePicker,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: DateField.textDark,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: widget.fontSize,
                color: DateField.textLight,
              ),
              prefixIcon: const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: DateField.textLight,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 34,
              ),
              filled: true,
              fillColor: DateField.inputBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: DateField.borderColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: DateField.borderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: DateField.primaryBlue,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: DateField.borderColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ControllerDate {
  final TextEditingController dateController = TextEditingController();

  Future<void> selectDate(BuildContext context) async {
    DateTime initialDateValue = DateTime.now();

    if (dateController.text.isNotEmpty) {
      try {
        final parts = dateController.text.split('/');
        if (parts.length == 3) {
          final int day = int.parse(parts[0]);
          final int month = int.parse(parts[1]);
          final int year = int.parse(parts[2]);
          initialDateValue = DateTime(year, month, day);
        }
      } catch (e) {
        initialDateValue = DateTime.now(); // Fallback if parsing fails
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateValue,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String month = pickedDate.month.toString();
      if (pickedDate.month
          .toString()
          .length == 1) {
        month = '0${pickedDate.month.toString()}';
      }

      String day = pickedDate.day.toString();
      if (pickedDate.day
          .toString()
          .length == 1) {
        day = '0${pickedDate.day.toString()}';
      }

      dateController.text = '$day/$month/${pickedDate.year}'.formatDate();
    }
  }
  String getDate() => dateController.text;
  String getDisplayDate()=> dateController.text.formatDate();

  void setDate(DateTime date) {
    dateController.text = date.toString();
  }

  void clear() {
    dateController.clear();
  }

  void dispose() {
    dateController.dispose();
  }
}