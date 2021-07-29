import 'package:flutter/material.dart';
import 'package:storyboard/channel/menu.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/toolbar.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/views/photo/create_photo_page.dart';

const String PHOTO_TOOLBAR = "PHOTO_TOOLBAR";

typedef VoidCallback = void Function();

class PhotoToolbarWidget extends StatefulWidget {
  @override
  PhotoToolbarState createState() => PhotoToolbarState();
}

class PhotoToolbarState extends State<StatefulWidget> {
  VoidCallback listener;

  showCreatePhotoPage(BuildContext context, String path) {
    if (path != null) {
      Navigator.of(context).pushNamed(
        CreatePhotoPage.routeName,
        arguments: CreatePhotoPageArguments(path),
      );
    }
  }

  void buildListener(BuildContext context) {
    if (listener != null) return;
    listener = () async {
      String path = await getViewResource().command.importPhotoFromDisk();
      showCreatePhotoPage(context, path);
    };
  }

  @override
  void initState() {
    super.initState();
    buildListener(context);
    getViewResource().menu.listenAction(MENU_IMPORT_PHOTO, listener);
  }

  @override
  void dispose() {
    getViewResource().menu.removeAction(MENU_IMPORT_PHOTO, listener);
    super.dispose();
  }

  void showTakePhotoActionSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  String path = await getViewResource().command.takePhoto();

                  BuildContext c1 = getViewResource()
                      .getGlobalKeyByName(HomePage.globalKey)
                      .currentContext;
                  showCreatePhotoPage(c1, path);
                },
              ),
              ListTile(
                title: Text("Import from Album"),
                onTap: () async {
                  Navigator.pop(context);
                  String path =
                      await getViewResource().command.importPhotoFromAlbum();

                  BuildContext c1 = getViewResource()
                      .getGlobalKeyByName(HomePage.globalKey)
                      .currentContext;
                  showCreatePhotoPage(c1, path);
                },
              ),
              Divider(
                height: MediaQuery.of(context).padding.bottom,
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    SBToolbarButton photoActionButton;
    if (getViewResource().deviceManager.isMobile()) {
      photoActionButton = SBToolbarButton(
        () {
          showTakePhotoActionSheet();
        },
        text: "ADD PHOTO",
        icon: Icon(AppIcons.picture),
      );
    } else {
      photoActionButton = SBToolbarButton(
        () async {
          String path = await getViewResource().command.importPhotoFromDisk();
          showCreatePhotoPage(context, path);
        },
        text: "ADD PHOTO",
        icon: Icon(AppIcons.picture),
      );
    }
    return SBToolbar(
      [
        photoActionButton,
      ],
      key: getViewResource().getGlobalKeyByName(PHOTO_TOOLBAR),
    );
  }
}
