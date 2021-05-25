import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/config/styles.dart';
import 'package:storyboard/views/home/photo/photo_toolbar_widget.dart';
import 'package:storyboard/views/home/photo/photo_widget.dart';

class ReduxActions {
  final List<Photo> photoList;
  final Status status;
  ReduxActions({this.status, this.photoList});
}

class PhotoListWidget extends StatelessWidget {
  final EdgeInsets padding;
  PhotoListWidget({this.padding = EdgeInsets.zero});

  List<Widget> buildList(ReduxActions redux) {
    var children = <Widget>[];

    var updatedPhotoList = List<Photo>.from(redux.photoList);
    updatedPhotoList.sort((Photo a, Photo b) {
      return a.updatedAt == b.updatedAt
          ? 0
          : (a.updatedAt > b.updatedAt ? 1 : -1);
    });
    updatedPhotoList.forEach((photo) {
      Widget w = PhotoWidget(uuid: photo.uuid);
      children.insert(0, w);
    });

    return children;
  }

  @override
  Widget build(Object context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        List<Photo> photoList = [];
        store.state.photoRepo.photos.forEach((uuid, photo) {
          if (photo.deleted == 0) {
            photoList.add(photo);
          }
        });

        return ReduxActions(
          status: store.state.status,
          photoList: photoList,
        );
      },
      builder: (context, ReduxActions redux) {
        return Container(
          decoration: BoxDecoration(
            color: Styles.photoBackColor,
          ),
          child: Column(children: [
            PhotoToolbarWidget(),
            Expanded(
              child: Container(
                padding: padding,
                child: GridView.extent(
                  childAspectRatio: 1,
                  maxCrossAxisExtent: 192,
                  children: buildList(redux),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}
