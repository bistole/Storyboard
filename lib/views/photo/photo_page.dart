import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/views/common/footerbar.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/photo/view_photo_widget.dart';
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
    final PhotoPageArguments args = ModalRoute.of(context).settings.arguments;
    var photoPath = getViewResource().storage.getPhotoPathByUUID(args.uuid);
    return OverflowBox(
      maxWidth: MediaQuery.of(context).size.width,
      maxHeight: MediaQuery.of(context).size.height - 44,
      child: ViewPhotoWidget(path: photoPath),
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

  Widget buildViewPhotoToolbar(ReduxActions redux) {
    return SBFooterbar([
      SBToolbarButton(
        () => {},
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
