import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/footerbar.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/constants.dart';
import 'package:storyboard/views/photo/origin_photo_widget.dart';
import 'package:storyboard/views/photo/photo_scroller_widget.dart';
import 'package:storyboard/views/common/toolbar_button.dart';

class ReduxActions {
  final Photo photo;
  final Function() getPhoto;
  ReduxActions({this.getPhoto, this.photo});
}

class PhotoPageArguments {
  final String uuid;
  PhotoPageArguments(this.uuid);
}

class PhotoPage extends StatefulWidget {
  static const routeName = '/photos';

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  int direction;

  @override
  void initState() {
    direction = 0;
    super.initState();
  }

  Widget buildPhotoWiget(BuildContext context, ReduxActions redux) {
    final PhotoPageArguments args = ModalRoute.of(context).settings.arguments;
    var photoPath = getViewResource().storage.getPhotoPathByUUID(args.uuid);
    return PhotoScollerWidget(path: photoPath);
  }

  Widget buildWaitingIndicator() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          strokeWidth: 1,
        ),
      ),
    );
  }

  Widget buildViewPhotoToolbar(ReduxActions redux) {
    return SBFooterbar([
      SBToolbarButton(
        () {
          setState(() {
            direction = (direction + 270) % 360;
            getViewResource().notifier.notifyListeners<int>(
                Constant.eventPhotoRotate,
                param: direction);
          });
        },
        icon: Icon(AppIcons.angle_left),
      ),
      SBToolbarButton(
        () {
          setState(() {
            direction = (direction + 90) % 360;
            getViewResource().notifier.notifyListeners<int>(
                Constant.eventPhotoRotate,
                param: direction);
          });
        },
        icon: Icon(AppIcons.angle_right),
      ),
      SBToolbarButton(
        () {
          getViewResource().notifier.notifyListeners(Constant.eventPhotoReset);
        },
        text: "RESET",
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final PhotoPageArguments args = ModalRoute.of(context).settings.arguments;
    return StoreConnector<AppState, ReduxActions>(
      converter: (Store<AppState> store) {
        return ReduxActions(
          getPhoto: () {
            getViewResource().actPhotos.actDownloadPhoto(store, args.uuid);
          },
          photo: store.state.photoRepo.photos[args.uuid],
        );
      },
      builder: (BuildContext context, ReduxActions redux) {
        if (redux.photo.hasOrigin == PhotoStatus.None) {
          redux.getPhoto();
        }
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(redux.photo.filename),
          ),
          body: Column(
            children: [
              Expanded(
                child: redux.photo.hasOrigin == PhotoStatus.Ready
                    ? buildPhotoWiget(context, redux)
                    : buildWaitingIndicator(),
              ),
              buildViewPhotoToolbar(redux),
            ],
          ),
        );
      },
    );
  }
}
