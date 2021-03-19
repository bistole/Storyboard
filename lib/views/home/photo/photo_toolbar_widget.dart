import 'package:flutter/material.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/toolbar.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/views/config/config.dart';

const String PHOTO_TOOLBAR = "PHOTO_TOOLBAR";

class PhotoToolbarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SBToolbarButton photoActionButton;
    if (getViewResource().deviceManager.isMobile()) {
      photoActionButton = SBToolbarButton(
        getViewResource().command.takePhoto,
        text: "TAKE PHOTO",
        icon: Icon(AppIcons.picture),
      );
    } else {
      photoActionButton = SBToolbarButton(
        getViewResource().command.importPhoto,
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
