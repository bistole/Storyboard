import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/photo/page.dart';

class ReduxActions {
  final Photo photo;
  final void Function() delete;
  final void Function() getThumb;
  ReduxActions({this.delete, this.getThumb, this.photo});

  @override
  int get hashCode => photo.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ReduxActions && photo == other.photo);
  }
}

class PhotoWidget extends StatelessWidget {
  final String uuid;

  PhotoWidget({this.uuid});

  Widget buildPopupMenu(BuildContext context, ReduxActions redux) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == 'delete') {
          redux.delete();
        } else if (value == 'show') {
          Navigator.of(context).pushNamed(
            PhotoPage.routeName,
            arguments: PhotoPageArguments(redux.photo.uuid),
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
      Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(width: 8, color: Colors.grey[100]),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          alignment: Alignment.center,
          child: Row(children: [
            Spacer(),
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
            Spacer(),
          ]),
        ),
      ),
      this.buildPopupMenu(context, redux),
    ];
  }

  List<Widget> buildThumb(BuildContext context, ReduxActions redux) {
    var photoPath = redux.photo.hasThumb == PhotoStatus.Ready
        ? getViewResource().storage.getThumbnailPathByUUID(this.uuid)
        : getViewResource().storage.getPhotoPathByUUID(this.uuid);
    List<Widget> children = [
      Expanded(
        child: FittedBox(
          fit: BoxFit.contain,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 1, minHeight: 1),
            child: Image.file(
              File(photoPath),
            ),
          ),
        ),
      ),
    ];
    if (redux.photo.ts == 0) {
      children.add(
        Container(
          height: 128,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.cloud_upload,
              size: 16,
              color: Colors.orange[700],
            ),
          ),
        ),
      );
    }
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
          child: Row(children: children),
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
            getViewResource().actPhotos.actDeletePhoto(store, this.uuid);
          },
          getThumb: () {
            getViewResource().actPhotos.actDownloadThumbnail(store, this.uuid);
          },
          photo: store.state.photoRepo.photos[this.uuid],
        );
      },
      builder: (context, ReduxActions redux) {
        // download if required
        if (redux.photo.hasThumb == PhotoStatus.None) {
          redux.getThumb();
        }
        return Row(
          children: redux.photo.hasThumb == PhotoStatus.Ready ||
                  redux.photo.hasOrigin == PhotoStatus.Ready
              ? this.buildThumb(context, redux)
              : this.buildLoadingIndicator(context, redux),
        );
      },
    );
  }
}
