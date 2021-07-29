import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/styles.dart';
import 'package:storyboard/views/photo/photo_page.dart';

class ReduxActions {
  final Photo photo;
  final void Function() delete;
  final void Function() getThumb;
  ReduxActions({this.delete, this.getThumb, this.photo});
}

class PhotoWidget extends StatefulWidget {
  final String uuid;

  PhotoWidget({this.uuid});

  @override
  PhotoWidgetState createState() => PhotoWidgetState();
}

class PhotoWidgetState extends State<PhotoWidget> {
  bool isMenuShown = false;

  @override
  void initState() {
    isMenuShown = false;
    super.initState();
  }

  void pushDetailPage(ReduxActions redux) {
    Navigator.of(context).pushNamed(
      PhotoPage.routeName,
      arguments: PhotoPageArguments(redux.photo.uuid, redux.photo.direction),
    );
  }

  void showMenu() {
    if (isMenuShown) return;
    setState(() {
      isMenuShown = true;
    });
  }

  void hideMenu() {
    if (!isMenuShown) return;
    setState(() {
      isMenuShown = false;
    });
  }

  Widget buildDeleteWidget(ReduxActions redux) {
    return AnimatedPositioned(
      width: 48,
      right: isMenuShown ? 0 : -48,
      top: 0,
      bottom: 0,
      curve: Curves.ease,
      duration: Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () => redux.delete(),
        child: Container(
          color: Styles.swiftPanelBackColor,
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.delete,
              color: Styles.buttonTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget wrapWidgetWithGestureDetector(ReduxActions redux, Widget child) {
    if (getViewResource().deviceManager.isDesktop()) {
      return MouseRegion(
        onEnter: (event) => showMenu(),
        onExit: (event) => hideMenu(),
        onHover: (event) => showMenu(),
        child: GestureDetector(
          key:
              getViewResource().getGlobalKeyByName("PHOTO-LIST:" + widget.uuid),
          onTap: () {
            pushDetailPage(redux);
          },
          child: child,
        ),
      );
    } else {
      return GestureDetector(
        key: getViewResource().getGlobalKeyByName("PHOTO-LIST:" + widget.uuid),
        onTap: () {
          if (isMenuShown) {
            hideMenu();
          } else {
            pushDetailPage(redux);
          }
        },
        onPanUpdate: (details) {
          if (details.delta.dx < 0) {
            showMenu();
          } else {
            hideMenu();
          }
        },
        onLongPress: () {
          showMenu();
        },
        child: child,
      );
    }
  }

  Widget wrapWidget(ReduxActions redux, List<Widget> children) {
    Widget container = Container(
      decoration: BoxDecoration(
        color: Styles.photoBackColor,
        border: Border.all(width: 1, color: Styles.borderColor),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      margin: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      child: Stack(children: [
        ...children,
        buildDeleteWidget(redux),
      ]),
    );
    return wrapWidgetWithGestureDetector(redux, container);
  }

  Widget buildLoadingIndicator(BuildContext context, ReduxActions redux) {
    return wrapWidget(redux, [
      Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 1,
          ),
        ),
      ),
    ]);
  }

  Widget buildThumb(BuildContext context, ReduxActions redux) {
    var photoPath = redux.photo.hasThumb == PhotoStatus.Ready
        ? getViewResource().storage.getThumbnailPathByUUID(widget.uuid)
        : getViewResource().storage.getPhotoPathByUUID(widget.uuid);
    List<Widget> children = [
      Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 1, minHeight: 1),
            child: RotatedBox(
              quarterTurns: redux.photo.direction ~/ 90,
              child: Image.file(
                File(photoPath),
              ),
            ),
          ),
        ),
      ),
    ];
    if (redux.photo.ts == 0) {
      children.add(
        Positioned(
          right: 0,
          top: 0,
          child: Icon(
            Icons.cloud_upload,
            size: 16,
            color: Styles.unsyncedColor,
          ),
        ),
      );
    }
    return wrapWidget(redux, children);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          delete: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListPhoto));
            getViewResource().actPhotos.actDeletePhoto(store, widget.uuid);
          },
          getThumb: () {
            getViewResource()
                .actPhotos
                .actDownloadThumbnail(store, widget.uuid);
          },
          photo: store.state.photoRepo.photos[widget.uuid],
        );
      },
      builder: (context, ReduxActions redux) {
        // download if required
        if (redux.photo.hasThumb == PhotoStatus.None) {
          redux.getThumb();
        }
        return (redux.photo.hasThumb == PhotoStatus.Ready ||
                redux.photo.hasOrigin == PhotoStatus.Ready)
            ? this.buildThumb(context, redux)
            : this.buildLoadingIndicator(context, redux);
      },
    );
  }
}
