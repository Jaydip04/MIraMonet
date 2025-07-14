import 'package:flutter/material.dart';

class Responsive {
  static double screenWidth = 0;
  static double screenHeight = 0;

  static void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }
  static double getMainHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  static double getMainWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  static double getHeight(double heightPx) {
    return (heightPx / 812) * screenHeight;
  }

  static double getWidth(double widthPx) {
    return (widthPx / 375) * screenWidth;
  }

  static double getFontSize(double fontSizePx) {
    return (fontSizePx / 375) * screenWidth;
  }
}
