import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/constants.dart';
import 'package:storyboard/views/photo/photo_scroller_controller.dart';
import 'package:storyboard/views/photo/photo_scroller_helper.dart';

import '../../common.dart';

void main() {
  group('PhotoScrollerHelper', () {
    test('getNextZoomState', () {
      var helper = PhotoScrollerHelper();

      expect(
        helper.getNextZoomState(Constant.zoomOrigin),
        Constant.zoomFitWidth,
      );

      expect(
        helper.getNextZoomState(Constant.zoomFitWidth),
        Constant.zoomFitHeight,
      );

      expect(
        helper.getNextZoomState(Constant.zoomFitHeight),
        Constant.zoomOrigin,
      );
    });

    test('getZoomDescription', () {
      var helper = PhotoScrollerHelper();

      expect(helper.getZoomDescription(Constant.zoomOrigin, 1), '100%');
      expect(helper.getZoomDescription(Constant.zoomFree, 100), 'x100');
      expect(helper.getZoomDescription(Constant.zoomFree, 5.3), 'x5.3');
      expect(helper.getZoomDescription(Constant.zoomFree, 0.73), '73.0%');
    });

    test('getNextScale', () {
      ViewsResource vr = MockViewResource();
      setViewResource(vr);
      when(vr.getGlobalKeyByName(any)).thenReturn(GlobalKey());
      when(vr.getSizeFromWidget(any)).thenReturn(Size(320, 420));

      var helper = PhotoScrollerHelper();

      // current: origin, next: fit width, scale: 0.5
      expect(helper.getNextScale('abc', Size(600, 400), 1.0), 0.5);
      // current: fit width, next: fit height, scale: 2.0
      expect(helper.getNextScale('abc', Size(600, 200), 0.5), 2.0);
      // current: fit height, next: origin, size: 1.0
      expect(helper.getNextScale('abc', Size(300, 200), 2.0), 1.0);
    });
  });

  group('PhotoScrollerControllerState', () {
    test('coverage', () {
      var s = PhotoScrollerControllerState();

      expect(s.hashCode, s.imageScale.hashCode ^ s.imageSize.hashCode);
      expect(s.toString(),
          'PhotoScrollerControllerState{size:Size(0.0, 0.0), scale:1.0}');
    });
  });
}
