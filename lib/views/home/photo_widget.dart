import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/actions/actions.dart';
import 'package:storyboard/models/app.dart';
import 'package:storyboard/models/photo.dart';
import 'package:storyboard/models/status.dart';
import 'package:storyboard/net/photos.dart';
import 'package:storyboard/storage/photo.dart';

class ReduxActions {
  final void Function() delete;
  final void Function() getThumb;
  ReduxActions({this.delete, this.getThumb});
}

class PhotoWidget extends StatelessWidget {
  final Photo photo;

  PhotoWidget({this.photo});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          delete: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
            deletePhoto(store, photo);
          },
          getThumb: () {
            downloadThumbnail(store, photo.uuid);
          },
        );
      },
      builder: (context, ReduxActions redux) {
        var photoPath = getThumbnailPathByUUID(this.photo.uuid);

        // download if required
        if (!this.photo.hasThumb) {
          redux.getThumb();
        }

        return ListTile(
          title: photo.hasThumb
              ? Image.file(File(photoPath))
              : CircularProgressIndicator(),
          trailing: PopupMenuButton(
            onSelected: (value) {
              if (value == 'delete') {
                redux.delete();
              }
            },
            icon: Icon(Icons.more_horiz),
            itemBuilder: (_) => <PopupMenuItem<String>>[
              new PopupMenuItem<String>(
                child: Text('Delete'),
                value: 'delete',
              ),
            ],
          ),
        );
      },
    );
  }
}
