import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Styles {
  static const primaryColor = Colors.green;
  static const transparentColor = Colors.transparent;

  static const buttonBackgroundColor = primaryColor;
  static const buttonTextColor = Colors.white;

  static const borderColor = Colors.grey;

  static const toolbarBorderColor = Color(0xFFE0E0E0); // grey 300
  static const toolbarBackColor = Colors.white;

  static const menuPanelBackColor = Colors.white;
  static const menuPanelSelectedBackColor = primaryColor;
  static const menuPanelColor = primaryColor;
  static const menuPanelSelectedColor = Colors.white;

  static const swiftPanelBackColor = Color(0x7FF44336); // red with 0.5 alpha

  static const photoBackColor = Color(0xFFF5F5F5); // grey 100

  static const taskBoardBackColor = Color(0xFFF5F5F5); // grey 100
  static const taskBackColor = Colors.white; // grey 100

  static const selectedColor = Colors.white;
  static const selectedBackColor = primaryColor;
  static const unselectedColor = Color(0xFF616161); // grey 700
  static const unselectedBackColor = Colors.grey;

  static const unknownColor = Colors.grey;
  static const succColor = Colors.green;
  static const errColor = Colors.red;

  static const unsyncedColor = Color(0xFFF57C00); // orange 700

  static const welcomeTextStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const titleTextStyle = TextStyle(fontSize: 18);
  static const colorTitleTextStyle =
      TextStyle(fontSize: 18, color: primaryColor);

  static const lessBodyText = TextStyle(fontSize: 14.0, color: Colors.grey);
  static const normalBodyText = TextStyle(fontSize: 14.0, color: Colors.black);
  static const boldBodyText = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  static const urlBodyText = TextStyle(
    fontSize: 14.0,
    color: Color(0xFF616161), // grey 700
    decoration: TextDecoration.underline,
  );

  static const errBodyText = TextStyle(fontSize: 14.0, color: errColor);

  static const divider = Divider(color: borderColor);
}
