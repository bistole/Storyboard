import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/footerbar.dart';
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
    return SBFooterbar([
      SBToolbarButton(
        () => redux.createPhoto(redux.status.param1),
        icon: Icon(AppIcons.ok),
        text: "OK",
      ),
      SBToolbarButton(
        redux.cancel,
        icon: Icon(AppIcons.cancel),
        text: "CANCEL",
      ),
    ]);
  }

  Widget buildWhenAddingPhoto(context, ReduxActions redux) {
    return Column(
      children: [
        Expanded(
          child: Container(
            child: Image.file(File(redux.status.param1)),
          ),
        ),
        buildAddingPhotoToolbar(redux),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          createPhoto: (String path) {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListPhoto));
            getViewResource().actPhotos.actUploadPhoto(store, path);
          },
          cancel: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListPhoto));
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
