import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewPhotoWidget extends StatefulWidget {
  final String path;

  ViewPhotoWidget({Key key, this.path}) : super(key: key);

  @override
  ViewPhotoWidgetState createState() => ViewPhotoWidgetState();
}

class ViewPhotoWidgetState extends State<ViewPhotoWidget> {
  PhotoViewController controller;

  @override
  void initState() {
    controller = PhotoViewController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildViewer() {
    return Container(
      child: PhotoView(
        maxScale: 2.0,
        minScale: 0.5,
        initialScale: 1.0,
        backgroundDecoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.white,
            width: 8,
          ),
        ),
        imageProvider: FileImage(File(widget.path)),
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          Offset o = event.scrollDelta;
          double f = sqrt(o.dx * o.dx + o.dy * o.dy) * (o.dy > 0 ? -1 : 1);
          double nextScale = controller.scale * (f + 100) / 100;
          if (nextScale < 2 && nextScale > 0.5) {
            controller.scale = nextScale;
          }
        }
      },
      child: buildViewer(),
    );
  }
}
