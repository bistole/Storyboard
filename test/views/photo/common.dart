import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/views/config/constants.dart';
import 'package:storyboard/views/photo/photo_scroller_controller.dart';
import 'package:storyboard/views/photo/photo_scroller_helper.dart';

class FakePhotoScrollerHelper extends Fake implements PhotoScrollerHelper {
  int times;
  FakePhotoScrollerHelper() {
    times = 0;
  }

  @override
  double getZoomFitWidthScale(String gKey, Size size) {
    return 2.0;
  }

  @override
  double getZoomFitHeightScale(String gKey, Size size) {
    return 0.5;
  }

  @override
  String getZoomDescription(String state, double scale) {
    return "100%";
  }

  String getNextZoomState(String state) {
    times++;
    return times % 2 == 0 ? Constant.zoomFitWidth : Constant.zoomFitHeight;
  }

  @override
  String getCurrentZoomState(String gKey, Size imageSize, double imageScale) {
    return Constant.zoomOrigin;
  }

  @override
  double getNextScale(String containerKey, Size imageSize, double imageScale) {
    times++;
    return times % 2 == 0
        ? getZoomFitWidthScale(containerKey, imageSize)
        : getZoomFitHeightScale(containerKey, imageSize);
  }

  @override
  Widget zoomBtn(
    BuildContext context,
    String zoomDesc,
    VoidCallback onPressed,
  ) {
    return TextButton(onPressed: onPressed, child: Text(zoomDesc));
  }
}

class FakePhotoScrollerController extends Fake
    implements PhotoScrollerController {
  PhotoScrollerHelper helper = FakePhotoScrollerHelper();
  StreamController<PhotoScrollerControllerState> _outputCtrl;
  Stream<PhotoScrollerControllerState> get outputStream => _outputCtrl.stream;

  FakePhotoScrollerController() {
    _outputCtrl = StreamController();
  }

  dispose() {
    _outputCtrl.close();
  }

  set value(v) => {};

  PhotoScrollerControllerState get value => PhotoScrollerControllerState(
        imageScale: 1.0,
        imageSize: Size(100, 100),
      );
}

class FakePhotoScrollerControllerFactory extends Fake
    implements PhotoScrollerControllerFactory {
  @override
  PhotoScrollerController createController() {
    return FakePhotoScrollerController();
  }
}

void setUpPhotoScrollerControllerFactory() {
  var fac = FakePhotoScrollerControllerFactory();
  setPhotoScrollerControllerFactory(fac);
}
