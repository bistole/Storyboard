import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/photo/view_photo_widget.dart';
import 'package:storyboard/views/common/toolbar.dart';
import 'package:storyboard/views/common/toolbar_button.dart';

class ReduxActions {
  final Status status;
  ReduxActions({this.status});
}

class PhotoPage extends StatelessWidget {
  final Photo photo;
  final PhotoViewController controller;

  PhotoPage({Key key, this.photo})
      : controller = PhotoViewController(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(this.photo.filename),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.tight(Size(
          s.width,
          s.height - 40,
        )),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 44,
              child: OverflowBox(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height - 44,
                child: ViewPhotoWidget(photo: this.photo),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 44,
              child: SBToolbar([
                SBToolbarButton("RESET", () => {}),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
