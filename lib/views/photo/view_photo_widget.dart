import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:photo_view/photo_view.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/storage/photo.dart';

class ReduxActions {
  final Status status;
  ReduxActions({this.status});
}

class ViewPhotoWidget extends StatefulWidget {
  final Photo photo;

  ViewPhotoWidget({Key key, this.photo}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          status: store.state.status,
        );
      },
      builder: (context, ReduxActions redux) {
        var photoPath = getPhotoPathByUUID(widget.photo.uuid);
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
          child: Container(
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
              imageProvider: FileImage(File(photoPath)),
              controller: controller,
            ),
          ),
        );
      },
    );
  }
}
