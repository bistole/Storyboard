import 'package:flutter/material.dart';

class Constant {
  static var eventPhotoReset = "PHOTO:RESET";
  static var eventPhotoRotate = "PHOTO:ROTATE";

  static var directionPortrait = 0;
  static var directionRight = 90;
  static var directionUpSideDown = 180;
  static var directionLeft = 270;

  static final photoBackgroundColor = Colors.grey[100];

  static final durationRotateAnimation = Duration(milliseconds: 200);
}
