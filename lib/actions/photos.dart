import 'dart:io';
import 'package:mime/mime.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/net/queue.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue_item.dart';
import 'package:storyboard/storage/storage.dart';
import 'package:uuid/uuid.dart';

class ActPhotos {
  // required
  NetQueue _netQueue;
  void setNetQueue(NetQueue netQueue) {
    _netQueue = netQueue;
  }

  // required
  Storage _storage;
  void setStorage(Storage storage) {
    _storage = storage;
  }

  void actFetchPhotos() {
    _netQueue.addQueueItem(
      QueueItemType.Photo,
      QueueItemAction.List,
      null,
    );
  }

  void actDownloadPhoto(Store<AppState> store, String uuid) {
    store.dispatch(DownloadPhotoAction(
      uuid: uuid,
      status: PhotoStatus.Loading,
    ));
    _netQueue.addQueueItem(
      QueueItemType.Photo,
      QueueItemAction.DownloadPhoto,
      uuid,
    );
  }

  void actDownloadThumbnail(Store<AppState> store, String uuid) {
    store.dispatch(ThumbnailPhotoAction(
      uuid: uuid,
      status: PhotoStatus.Loading,
    ));
    _netQueue.addQueueItem(
      QueueItemType.Photo,
      QueueItemAction.DownloadThumbnail,
      uuid,
    );
  }

  var validMimeTypes = ["image/jpeg", "image/png", "image/gif"];

  void actUploadPhoto(Store<AppState> store, String path) async {
    var mimeType = lookupMimeType(path);
    if (!validMimeTypes.contains(mimeType)) {
      // TODO: show error in UI
      return;
    }

    String uuid = Uuid().v4();
    List<String> comp = path.split("/");
    String filename = comp[comp.length - 1];
    String size = File(path).lengthSync().toString();
    int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Photo photo = Photo(
      uuid: uuid,
      filename: filename,
      mime: mimeType,
      size: size,
      hasOrigin: PhotoStatus.Ready,
      hasThumb: PhotoStatus.None,
      deleted: 0,
      updatedAt: ts,
      createdAt: ts,
      ts: 0,
    );
    await _storage.copyPhotoByUUID(uuid, File(path));
    store.dispatch(CreatePhotoAction(photo: photo));
    _netQueue.addQueueItem(
      QueueItemType.Photo,
      QueueItemAction.Upload,
      uuid,
    );
  }

  void actDeletePhoto(Store<AppState> store, String uuid) {
    Photo photo = store.state.photoRepo.photos[uuid];
    int ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Photo newPhoto = photo.copyWith(
      deleted: 1,
      updatedAt: ts,
    );
    store.dispatch(UpdatePhotoAction(photo: newPhoto));
    _netQueue.addQueueItem(
      QueueItemType.Photo,
      QueueItemAction.Delete,
      uuid,
    );
  }
}
