import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:storyboard/helper/image_helper.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/constants.dart';
import 'package:storyboard/views/photo/origin_photo_widget.dart';
import 'package:storyboard/views/photo/photo_scroller_controller.dart';

class PhotoScrollerWidget extends StatefulWidget {
  final String path;
  final int direction;
  final PhotoScrollerController controller;

  PhotoScrollerWidget(
      {@required this.path, this.direction = 0, this.controller});

  @override
  _PhotoScrollerWidgetState createState() => _PhotoScrollerWidgetState();
}

class _PhotoScrollerWidgetState extends State<PhotoScrollerWidget>
    with TickerProviderStateMixin {
  ui.Image image;
  ui.Image currentImage;
  ui.Image nextImage;
  int direction;
  int nextDirection;
  AnimationController animateController;
  PhotoViewController viewController;

  updateOutputController({double imageScale, Size imageSize}) {
    if (widget.controller != null) {
      widget.controller.value = PhotoScrollerControllerState(
        imageScale: imageScale ?? widget.controller.value.imageScale,
        imageSize: imageSize ?? widget.controller.value.imageSize,
      );
    }
  }

  doScale() {
    var value =
        getViewResource().notifier.getValue<double>(Constant.eventPhotoScale);
    viewController.scale = value;
  }

  doRotate() async {
    var value =
        getViewResource().notifier.getValue<int>(Constant.eventPhotoRotate);

    // generate image
    Future.delayed(Duration.zero, () async {
      var newImage = await getImageHelper().rotateImage(image, value);
      setState(() {
        nextImage = newImage;
        nextDirection = value;
        animateController.value = 0;
        animateController.forward();
      });
    });
  }

  void viewListener(PhotoViewControllerValue value) {
    updateOutputController(imageScale: value.scale);
  }

  @override
  void initState() {
    image = null;
    direction = widget.direction;
    nextDirection = widget.direction;
    viewController = PhotoViewController()
      ..outputStateStream.listen(viewListener);
    animateController = AnimationController(
        value: 0.0, vsync: this, duration: Constant.durationRotateAnimation);

    getViewResource().notifier.registerNotifier(Constant.eventPhotoScale);
    getViewResource().notifier.addListener(Constant.eventPhotoScale, doScale);

    getViewResource().notifier.registerNotifier<int>(Constant.eventPhotoRotate);
    getViewResource().notifier.addListener(Constant.eventPhotoRotate, doRotate);
    super.initState();

    // generate image
    Future.delayed(Duration.zero, () async {
      var newImage = await getImageHelper().loadImage(widget.path);
      var newCurrImage =
          await getImageHelper().rotateImage(newImage, direction);
      setState(() {
        image = newImage;
        currentImage = newCurrImage;
        updateOutputController(
          imageSize: Size(
            currentImage.width.toDouble(),
            currentImage.height.toDouble(),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    viewController.dispose();
    animateController.dispose();

    getViewResource()
        .notifier
        .removeListener(Constant.eventPhotoScale, doScale);
    getViewResource()
        .notifier
        .removeListener(Constant.eventPhotoRotate, doRotate);
    super.dispose();
  }

  Widget buildViewer(Size childSize) {
    return Container(
      decoration: BoxDecoration(color: Constant.photoBackgroundColor),
      child: PhotoView.customChild(
        backgroundDecoration: BoxDecoration(color: Colors.transparent),
        initialScale: viewController.scale,
        childSize: childSize,
        child: OriginPhotoWidget(
          image: currentImage,
          direction: 0,
        ),
        controller: viewController,
      ),
    );
  }

  Widget buildViewerAnimation(Size childSize) {
    var scale = Tween<double>(
      begin: 1,
      end: 1,
    ).animate(animateController);

    var turnsBegin = (direction - nextDirection) / 360.0 + 1;
    if (turnsBegin < 0.5) {
      turnsBegin += 1;
    } else if (turnsBegin > 1.5) {
      turnsBegin -= 1;
    }
    var turns = Tween<double>(
      begin: turnsBegin,
      end: 1,
    ).animate(animateController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            if (direction != nextDirection) {
              currentImage = nextImage;
              direction = nextDirection;
              updateOutputController(
                imageSize: Size(
                  currentImage.width.toDouble(),
                  currentImage.height.toDouble(),
                ),
              );
            }
          });
        }
      });

    return Container(
      decoration: BoxDecoration(color: Constant.photoBackgroundColor),
      child: RotationTransition(
        turns: turns,
        child: ScaleTransition(
          scale: scale,
          child: PhotoView.customChild(
            initialScale: viewController.scale,
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
            childSize: childSize,
            child: OriginPhotoWidget(
              image: nextImage,
              direction: 0,
            ),
            controller: viewController,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (image == null || currentImage == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    var childSize = direction == Constant.directionLeft ||
            direction == Constant.directionRight
        ? Size(image.height.toDouble(), image.width.toDouble())
        : Size(image.width.toDouble(), image.height.toDouble());

    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          Offset o = event.scrollDelta;
          double f = math.sqrt(o.dx * o.dx + o.dy * o.dy) * (o.dy > 0 ? -1 : 1);
          double nextScale = viewController.scale * (f + 100) / 100;
          if (nextScale < 2 && nextScale > 0.5) {
            viewController.scale = nextScale;
          }
        }
      },
      child: direction == nextDirection
          ? buildViewer(childSize)
          : buildViewerAnimation(childSize),
    );
  }
}
