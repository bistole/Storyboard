import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/photo/view_photo_widget.dart';
import 'package:storyboard/views/common/toolbar.dart';
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

class PhotoPage extends StatelessWidget {
  static const routeName = '/photos';

  Widget buildPhotoWiget(BuildContext context, ReduxActions redux) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 44,
      child: OverflowBox(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height - 44,
        child: ViewPhotoWidget(photo: redux.photo),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final PhotoPageArguments args = ModalRoute.of(context).settings.arguments;
    Size s = MediaQuery.of(context).size;
    return StoreConnector<AppState, ReduxActions>(
      converter: (Store<AppState> store) {
        return ReduxActions(
          getPhoto: () {
            getViewResource().actPhotos.actDownloadPhoto(store, args.uuid);
          },
          photo: store.state.photos[args.uuid],
        );
      },
      builder: (BuildContext context, ReduxActions redux) {
        if (!redux.photo.hasOrigin) {
          redux.getPhoto();
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(redux.photo.filename),
          ),
          body: ConstrainedBox(
            constraints: BoxConstraints.tight(Size(
              s.width,
              s.height - 40,
            )),
            child: Stack(
              children: [
                redux.photo.hasOrigin
                    ? buildPhotoWiget(context, redux)
                    : buildWaitingIndicator(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 44,
                  child: SBToolbar([
                    SBToolbarButton("RESET", () => {}),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
