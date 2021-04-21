import 'package:flutter/widgets.dart';
import 'package:storyboard/views/common/view_state_controller.dart';
import 'package:storyboard/views/photo/photo_scroller_helper.dart';

class PhotoScrollerControllerState {
  Size imageSize;
  double imageScale;

  PhotoScrollerControllerState({Size imageSize, double imageScale})
      : this.imageScale = imageScale ?? 1.0,
        this.imageSize = imageSize ?? Size.zero;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoScrollerControllerState &&
          runtimeType == other.runtimeType &&
          imageSize == other.imageSize &&
          imageScale == other.imageScale;

  @override
  int get hashCode => imageSize.hashCode ^ imageScale.hashCode;

  @override
  String toString() {
    return 'PhotoScrollerControllerState{size: $imageSize, scale: $imageScale}';
  }
}

class PhotoScrollerController
    extends ViewStateController<PhotoScrollerControllerState> {
  PhotoScrollerHelper helper;
  PhotoScrollerController(PhotoScrollerControllerState initial)
      : helper = PhotoScrollerHelper(),
        super(initial);
}

class PhotoScrollerControllerFactory {
  PhotoScrollerController createController() {
    return PhotoScrollerController(PhotoScrollerControllerState());
  }
}

PhotoScrollerControllerFactory _factory;
void setPhotoScrollerControllerFactory(PhotoScrollerControllerFactory fac) {
  _factory = fac;
}

PhotoScrollerControllerFactory getPhotoScrollerControllerFactory() {
  if (_factory == null) {
    _factory = PhotoScrollerControllerFactory();
  }
  return _factory;
}
