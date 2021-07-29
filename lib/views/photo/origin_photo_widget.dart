import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:storyboard/views/config/constants.dart';

class OriginPhotoWidget extends StatelessWidget {
  final ui.Image image;
  final int direction;

  OriginPhotoWidget({Key key, @required this.image, @required this.direction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = image.width.toDouble();
    var height = image.height.toDouble();
    if (direction == Constant.directionLeft ||
        direction == Constant.directionRight) {
      var swap = width;
      width = height;
      height = swap;
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var width = constraints.maxWidth;
        var height = constraints.maxHeight;

        return Center(
          child: CustomPaint(
            painter: _ImagePainter(image, width, height),
          ),
        );
      },
    );
  }
}

class _ImagePainter extends CustomPainter {
  final ui.Image image;
  final double width;
  final double height;

  _ImagePainter(this.image, this.width, this.height);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    double dx = (size.width - image.width) / 2;
    double dy = (size.height - image.height) / 2;
    canvas.drawImage(image, Offset(dx, dy), Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
