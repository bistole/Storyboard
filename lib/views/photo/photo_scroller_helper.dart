import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/constants.dart';

class PhotoScrollerHelper {
  static double threshold = 0.05;

  double getZoomFitWidthScale(String containerKey, Size imageSize) {
    if (imageSize == null) {
      return null;
    }
    GlobalKey gKey = getViewResource().getGlobalKeyByName(containerKey);
    var containerSize = getViewResource().getSizeFromWidget(gKey);
    return (containerSize.width.toDouble() - 20.0) / imageSize.width.toDouble();
  }

  double getZoomFitHeightScale(String containerKey, Size imageSize) {
    if (imageSize == null) {
      return null;
    }
    GlobalKey gKey = getViewResource().getGlobalKeyByName(containerKey);
    var containerSize = getViewResource().getSizeFromWidget(gKey);
    return (containerSize.height.toDouble() - 20.0) /
        imageSize.height.toDouble();
  }

  bool isScale(double scale, double rangeScale) {
    return (scale > rangeScale * (1.0 - threshold) &&
        scale < rangeScale * (1.0 + threshold));
  }

  String getCurrentZoomState(
    String containerKey,
    Size imageSize,
    double imageScale,
  ) {
    if (imageSize == null) return Constant.zoomFree;

    if (isScale(imageScale, 1.0)) {
      return Constant.zoomOrigin;
    } else if (isScale(
        imageScale, getZoomFitWidthScale(containerKey, imageSize))) {
      return Constant.zoomFitWidth;
    } else if (isScale(
        imageScale, getZoomFitHeightScale(containerKey, imageSize))) {
      return Constant.zoomFitHeight;
    } else {
      return Constant.zoomFree;
    }
  }

  String getNextZoomState(String currentState) {
    switch (currentState) {
      case Constant.zoomOrigin:
        return Constant.zoomFitWidth;
      case Constant.zoomFitWidth:
        return Constant.zoomFitHeight;
    }
    return Constant.zoomOrigin;
  }

  String getZoomDescription(String state, double scale) {
    switch (state) {
      case Constant.zoomOrigin:
        return "100%";
      case Constant.zoomFitHeight:
        return "^- H -v";
      case Constant.zoomFitWidth:
        return "<- W ->";
    }

    if (scale > 10) {
      return "x" + (scale.toInt()).toString();
    }
    if (scale > 1) {
      return "x" + ((scale * 10).toInt() / 10).toString();
    }
    return "" + ((scale * 1000).toInt() / 10).toString() + "%";
  }

  double getNextScale(String containerKey, Size imageSize, double imageScale) {
    var zoomCurrentState =
        getCurrentZoomState(containerKey, imageSize, imageScale);
    var zoomNextState = getNextZoomState(zoomCurrentState);
    // do next
    double scale = 1.0;
    if (zoomNextState == Constant.zoomFitWidth) {
      scale = getZoomFitWidthScale(containerKey, imageSize);
    } else if (zoomNextState == Constant.zoomFitHeight) {
      scale = getZoomFitHeightScale(containerKey, imageSize);
    }
    return scale;
  }

  Widget zoomBtn(BuildContext context, String zoomDesc, VoidCallback onPress) {
    return Container(
      width: 75,
      child: TextButton(
        onPressed: onPress,
        child: FittedBox(
          fit: BoxFit.cover,
          child: Text(zoomDesc),
        ),
        style: ButtonStyle(
          padding:
              MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16)),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }
}
