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
        return "^- Height -v";
      case Constant.zoomFitWidth:
        return "<- Width ->";
    }
    return "" + ((scale * 10000).toInt() / 100).toString() + "%";
  }
}
