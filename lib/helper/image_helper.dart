import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:storyboard/views/config/constants.dart';

class ImageHelper {
  Future<ui.Image> loadImage(String path) async {
    var f = File(path);
    Uint8List bytes = f.readAsBytesSync();
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<ui.Image> rotateImage(ui.Image image, int direction) async {
    if (direction == Constant.directionPortrait) return image;

    var picRecorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(picRecorder);
    if (direction == Constant.directionRight) {
      canvas.translate(image.height.toDouble(), 0);
    } else if (direction == Constant.directionLeft) {
      canvas.translate(0, image.width.toDouble());
    } else {
      canvas.translate(image.width.toDouble(), image.height.toDouble());
    }
    canvas.rotate(direction * math.pi / 180);
    canvas.drawImage(image, ui.Offset.zero, ui.Paint());
    if (direction == Constant.directionRight ||
        direction == Constant.directionLeft) {
      return picRecorder.endRecording().toImage(image.height, image.width);
    } else {
      return picRecorder.endRecording().toImage(image.width, image.height);
    }
  }
}

ImageHelper _helper;

ImageHelper getImageHelper() {
  if (_helper == null) {
    _helper = ImageHelper();
  }
  return _helper;
}

void setImageHelper(ImageHelper helper) {
  _helper = helper;
}
