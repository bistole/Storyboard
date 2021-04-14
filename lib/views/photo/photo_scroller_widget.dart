import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/constants.dart';
import 'package:storyboard/views/photo/origin_photo_widget.dart';

class PhotoScollerWidget extends StatefulWidget {
  final String path;
  final int direction;

  PhotoScollerWidget({@required this.path, this.direction = 0});

  @override
  _PhotoScollerWidgetState createState() => _PhotoScollerWidgetState();
}

class _PhotoScollerWidgetState extends State<PhotoScollerWidget>
    with TickerProviderStateMixin {
  ui.Image image;
  ui.Image currentImage;
  ui.Image nextImage;
  int direction;
  int nextDirection;
  AnimationController animateController;
  PhotoViewController viewController;

  doReset() {
    viewController.scale = 1;
  }

  doRotate() async {
    var value =
        getViewResource().notifier.getValue<int>(Constant.eventPhotoRotate);

    // generate image
    Future.delayed(Duration.zero, () async {
      var newImage = await rotateImage(image, value);
      setState(() {
        nextImage = newImage;
        nextDirection = value;
        animateController.value = 0;
        animateController.forward();
      });
    });
  }

  @override
  void initState() {
    image = null;
    direction = widget.direction;
    nextDirection = widget.direction;
    viewController = PhotoViewController();
    animateController = AnimationController(
        value: 0.0, vsync: this, duration: Constant.durationRotateAnimation);

    getViewResource().notifier.registerNotifier(Constant.eventPhotoReset);
    getViewResource().notifier.addListener(Constant.eventPhotoReset, doReset);

    getViewResource().notifier.registerNotifier<int>(Constant.eventPhotoRotate);
    getViewResource().notifier.addListener(Constant.eventPhotoRotate, doRotate);
    super.initState();

    // generate image
    Future.delayed(Duration.zero, () async {
      var newImage = await loadImage(widget.path);
      var newCurrImage = await rotateImage(newImage, direction);
      setState(() {
        image = newImage;
        currentImage = newCurrImage;
      });
    });
  }

  @override
  void dispose() {
    viewController.dispose();
    animateController.dispose();

    getViewResource()
        .notifier
        .removeListener(Constant.eventPhotoReset, doReset);
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

  Future<ui.Image> loadImage(String path) async {
    var f = File(path);
    Uint8List bytes = await f.readAsBytes();
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<ui.Image> rotateImage(ui.Image image, int direction) async {
    if (direction == Constant.directionPortrait) return image;

    var picRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(picRecorder);

    if (direction == Constant.directionRight) {
      canvas.translate(image.height.toDouble(), 0);
    } else if (direction == Constant.directionLeft) {
      canvas.translate(0, image.width.toDouble());
    } else {
      canvas.translate(image.width.toDouble(), image.height.toDouble());
    }
    canvas.rotate(direction * math.pi / 180);

    canvas.drawImage(image, Offset.zero, Paint());
    if (direction == Constant.directionRight ||
        direction == Constant.directionLeft) {
      return picRecorder.endRecording().toImage(image.height, image.width);
    } else {
      return picRecorder.endRecording().toImage(image.width, image.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (image == null || currentImage == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    print("build 2");
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
