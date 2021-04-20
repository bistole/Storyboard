import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/footerbar.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/constants.dart';
import 'package:storyboard/views/photo/photo_scroller_widget.dart';

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

  @override
  String toString() {
    return "PhotoPageArguments{ path: $path }";
  }
}

class CreatePhotoPage extends StatefulWidget {
  static const routeName = '/photos/new';

  final CreatePhotoPageArguments args;

  CreatePhotoPage(this.args);

  @override
  _CreatePhotoPageState createState() => _CreatePhotoPageState();
}

class _CreatePhotoPageState extends State<CreatePhotoPage> {
  PhotoScrollerWidget scoller;
  int direction;

  @override
  initState() {
    direction = 0;
    super.initState();
  }

  Widget buildAddingPhotoToolbar(ReduxActions redux) {
    return SBFooterbar([
      SBToolbarButton(
        () {
          setState(() {
            direction = (direction + 270) % 360;
            getViewResource().notifier.notifyListeners<int>(
                Constant.eventPhotoRotate,
                param: direction);
          });
        },
        icon: Icon(AppIcons.angle_left),
      ),
      SBToolbarButton(
        () {
          setState(() {
            direction = (direction + 90) % 360;
            getViewResource().notifier.notifyListeners<int>(
                Constant.eventPhotoRotate,
                param: direction);
          });
        },
        icon: Icon(AppIcons.angle_right),
      ),
      SBToolbarButton(
        () {
          getViewResource()
              .notifier
              .notifyListeners<double>(Constant.eventPhotoScale, param: 1);
        },
        text: "SCALE",
      ),
      SBToolbarButton(
        () => redux.createPhoto(widget.args.path),
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
          child: PhotoScrollerWidget(path: widget.args.path),
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
            getViewResource()
                .actPhotos
                .actUploadPhoto(store, widget.args.path, direction);
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
          body: buildWhenAddingPhoto(context, redux),
        );
      },
    );
  }
}
