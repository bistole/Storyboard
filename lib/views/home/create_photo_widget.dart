import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/common/toolbar.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/views/config/config.dart';

class ReduxActions {
  final void Function(String) createPhoto;
  final void Function() cancel;
  final Status status;
  ReduxActions({
    this.createPhoto,
    this.cancel,
    this.status,
  });
}

class CreatePhotoWidget extends StatelessWidget {
  Widget buildAddingPhotoToolbar(ReduxActions redux) {
    return SBToolbar([
      SBToolbarButton("ADD", () => redux.createPhoto(redux.status.param1)),
      SBToolbarButton("CANCEL", redux.cancel),
    ]);
  }

  Widget buildWhenAddingPhoto(context, ReduxActions redux) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 44,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 44,
            child: Container(
              child: Image.file(File(redux.status.param1)),
            ),
          ),
          Positioned(
            bottom: 0,
            height: 44,
            left: 0,
            right: 0,
            child: buildAddingPhotoToolbar(redux),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          createPhoto: (String path) {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
            getViewResource().actPhotos.actUploadPhoto(store, path);
          },
          cancel: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
          },
          status: store.state.status,
        );
      },
      builder: (context, ReduxActions redux) {
        return buildWhenAddingPhoto(context, redux);
      },
    );
  }
}
