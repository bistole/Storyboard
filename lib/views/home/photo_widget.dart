import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/actions/photos.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/storage/photo.dart';
import 'package:storyboard/views/photo/page.dart';

class ReduxActions {
  final void Function() delete;
  final void Function() getThumb;
  ReduxActions({this.delete, this.getThumb});
}

class PhotoWidget extends StatelessWidget {
  final Photo photo;

  PhotoWidget({this.photo});

  Widget buildPopupMenu(BuildContext context, ReduxActions redux) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == 'delete') {
          redux.delete();
        } else if (value == 'show') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoPage(photo: photo),
            ),
          );
        }
      },
      icon: Icon(Icons.more_horiz),
      itemBuilder: (_) => <PopupMenuItem<String>>[
        PopupMenuItem<String>(
          child: Text('Delete'),
          value: 'delete',
        ),
        PopupMenuItem<String>(
          child: Text('Show'),
          value: 'show',
        ),
      ],
    );
  }

  List<Widget> buildLoadingIndicator(BuildContext context, ReduxActions redux) {
    return [
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(width: 8, color: Colors.grey[100]),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        width: 48,
        height: 48,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: CircularProgressIndicator(
          strokeWidth: 1,
        ),
      ),
      Spacer(),
      this.buildPopupMenu(context, redux),
    ];
  }

  List<Widget> buildThumb(BuildContext context, ReduxActions redux) {
    var photoPath = getThumbnailPathByUUID(this.photo.uuid);
    return [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(width: 8, color: Colors.grey[100]),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          height: 128,
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.file(
              File(photoPath),
            ),
          ),
        ),
      ),
      this.buildPopupMenu(context, redux),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          delete: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
            getActPhotos().actDeletePhoto(store, photo.uuid);
          },
          getThumb: () {
            getActPhotos().actDownloadThumbnail(store, photo.uuid);
          },
        );
      },
      builder: (context, ReduxActions redux) {
        // download if required
        if (!this.photo.hasThumb) {
          redux.getThumb();
        }

        return Row(
          children:
              // ...this.buildLoadingIndicator(),
              this.photo.hasThumb
                  ? this.buildThumb(context, redux)
                  : this.buildLoadingIndicator(context, redux),
        );
      },
    );
  }
}
