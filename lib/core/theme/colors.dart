
import 'package:flutter/material.dart';

Color primaryAppColor = const Color(0xFF3470ED);
Color primaryPurpleLite = const Color(0xff8E7BFF);
Color primaryPurpleMedium = const Color(0xff6A5CFF);
Color primaryPurpleDark = const Color(0xFF121E51);
Color colorOrangeGr3 = const Color(0xFFEEF7FF);
Color colorOrangeMid = const Color(0xFFFF7A00);
Color colorLightFace = const Color(0xFFF1E7F2);
Color colorRedMid = const Color(0xFFE82323);
Color colorGreenMid = const Color(0xFF44EA92);
const Color primaryBlue = Color(0xff123F78);
const Color blue = Color(0xff2563EB);
const Color textDark = Color(0xff334155);
const Color textMedium = Color(0xff64748B);
const Color textLight = Color(0xff94A3B8);
const Color borderColor = Color(0xffd3d8dd);
const Color themeColor = Color(0xff97004d);

class AppColors {
  static const List<Color> colors = [
    Color(0xFFE57373), // Red
    Color(0xFF64B5F6), // Blue
    Color(0xFF81C784), // Green
    Color(0xFFFFB74D), // Orange
    Color(0xFFBA68C8), // Purple
    Color(0xFF4DB6AC), // Teal
    Color(0xFFFF8A65), // Deep Orange
    Color(0xFFA1887F), // Brown
    Color(0xFF90A4AE), // Blue Grey
    Color(0xFFF06292), // Pink
  ];

  static Color getColor(int index) {
    return colors[index % colors.length];
  }
}