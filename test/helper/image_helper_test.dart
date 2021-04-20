import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/helper/image_helper.dart';

import '../common.dart';

void main() {
  group('ImageHelper', () {
    test('load & rotate', () async {
      ImageHelper helper = ImageHelper();

      String resourcePath = getResourcePath("test_resources/photo_test.jpg");
      ui.Image image = await helper.loadImage(resourcePath);
      expect(image, isNotNull);

      ui.Image rotatedImage = await helper.rotateImage(image, 270);
      expect(rotatedImage, isNotNull);
    });
  });
}
