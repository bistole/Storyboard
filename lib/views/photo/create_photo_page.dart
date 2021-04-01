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
import 'package:storyboard/views/photo/view_photo_widget.dart';

class ReduxActions {
  final void Function(String) createPhoto;
  final void Function() cancel;
  ReduxActions({
    this.createPhoto,
    this.cancel,
  });
}

class CreatePhotoPageArguments {
  final String path;
  CreatePhotoPageArguments(this.path);
}

class CreatePhotoPage extends StatelessWidget {
  static const routeName = '/photos/new';

  Widget buildAddingPhotoToolbar(
      CreatePhotoPageArguments args, ReduxActions redux) {
    return SBFooterbar([
      SBToolbarButton(
        () => redux.createPhoto(args.path),
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

  Widget buildWhenAddingPhoto(
      context, CreatePhotoPageArguments args, ReduxActions redux) {
    return Column(
      children: [
        Expanded(
          child: OverflowBox(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height - 44,
            child: ViewPhotoWidget(path: args.path),
          ),
        ),
        buildAddingPhotoToolbar(args, redux),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final CreatePhotoPageArguments args =
        ModalRoute.of(context).settings.arguments;
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          createPhoto: (String path) {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListPhoto));
            getViewResource().actPhotos.actUploadPhoto(store, args.path);
            Navigator.of(context).pop();
          },
          cancel: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListPhoto));
            Navigator.of(context).pop();
          },
        );
      },
      builder: (context, ReduxActions redux) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text("New Photo"),
          ),
          body: buildWhenAddingPhoto(context, args, redux),
        );
      },
    );
  }
}
